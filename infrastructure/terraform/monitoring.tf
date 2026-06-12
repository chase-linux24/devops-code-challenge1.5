# ── Monitoring EC2 Instance ───────────────────────────
data "aws_ami" "amazon_linux_2023" {
    most_recent = true
    owners      = ["amazon"]

    filter {
        name  = "name"
        values = ["al2023-ami-*-x86_64"]
    }

    filter {
        name    = "virtualization-type"
        values  = ["hvm"]
    }
}

resource "aws_instance" "monitoring" {
    ami                    = data.aws_ami.amazon_linux_2023.id
    instance_type          =  var.monitoring_instance_type
    key_name               = var.key_pair_name
    subnet_id              = aws_subnet.public[0].id
    vpc_security_group_ids = [aws_security_group.monitoring.id]

    root_block_device {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }

    user_data = <<-EOF
    #!/bin/bash
    set -e 

    # ── System Update ─────────────────────────────────
    dnf update -y
    dnf install -y wget curl tar

    # ── Install Prometheus ────────────────────────────
    PROMETHEUS_VERSION="2.51.0"
    cd /tmp
    wget https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
    tar -xzf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
    mv prometheus-$PROMETHEUS_VERSION.linux-amd64/prometheus /usr/local/bin/
    mv prometheus-$PROMETHEUS_VERSION.linux-amd64/promtool /usr/local/bin/
    mkdir -p /etc/prometheus /var/lib/prometheus

    # ── Prometheus Configuration ──────────────────────
    cat > /etc/prometheus/prometheus.yml << 'PROMCONFIG'
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    alerting:
      alertmanagers:
        - static_configs:
            - targets: ['localhost:9093']

    rule_files:
      - "/etc/prometheus/alert.rules.yml"

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      - job_name: 'backend'
        static_configs:
          - targets: ['BACKEND_IP:8080']
        metrics_path: '/metrics'

    PROMCONFIG

    # ── Prometheus Alert Rules ────────────────────────
    cat > /etc/prometheus/alert.rules.yml << 'ALERTRULES'
    groups:
      - name: backend_alerts
        rules:
          - alert: BackendDown
            expr: up{job="backend"} == 0
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "Backend service is down"
              description: "Prometheus cannot scrape the backend"

          - alert: HighErrorRate
            expr: rate(http_requests_total{status_code=~"5.."}[5m]) > 0.05
            for: 2m
            labels:
              severity: warning
            annotations:
              summary: "High error rate detected"
              description: "More than 5% of requests returning 5xx errors"

          - alert: HighResponseTime
            expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
            for: 2m
            labels:
              severity: warning
            annotations:
              summary: "High response time"
              description: "95th percentile response time above 500ms"

    ALERTRULES

    # ── Prometheus Systemd Service ────────────────────
    useradd --no-create-home --shell /bin/false prometheus
    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

    cat > /etc/systemd/system/prometheus.service << 'PROMSVC'
    [Unit]
    Description=Prometheus
    After=network.target

    [Service]
    User=prometheus
    ExecStart=/usr/local/bin/prometheus \
      --config.file=/etc/prometheus/prometheus.yml \
      --storage.tsdb.path=/var/lib/prometheus \
      --web.console.templates=/etc/prometheus/consoles \
      --web.console.libraries=/etc/prometheus/console_libraries \
      --storage.tsdb.retention.time=15d
    Restart=always

    [Install]
    WantedBy=multi-user.target
    PROMSVC

    systemctl daemon-reload
    systemctl enable prometheus
    systemctl start prometheus

    # ── Install AlertManager ──────────────────────────
    ALERTMANAGER_VERSION="0.27.0"
    cd /tmp
    wget https://github.com/prometheus/alertmanager/releases/download/v$ALERTMANAGER_VERSION/alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz
    tar -xzf alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz
    mv alertmanager-$ALERTMANAGER_VERSION.linux-amd64/alertmanager /usr/local/bin/
    mkdir -p /etc/alertmanager

    cat > /etc/alertmanager/alertmanager.yml << 'ALERTCONFIG'
    global:
      resolve_timeout: 5m

    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'

    receivers:
      - name: 'web.hook'
        webhook_configs:
          - url: 'http://localhost:5001/'

    ALERTCONFIG

    useradd --no-create-home --shell /bin/false alertmanager
    chown -R alertmanager:alertmanager /etc/alertmanager

    cat > /etc/systemd/system/alertmanager.service << 'ALERTSVC'
    [Unit]
    Description=AlertManager
    After=network.target

    [Service]
    User=alertmanager
    ExecStart=/usr/local/bin/alertmanager \
      --config.file=/etc/alertmanager/alertmanager.yml \
      --storage.path=/var/lib/alertmanager
    Restart=always

    [Install]
    WantedBy=multi-user.target
    ALERTSVC

    mkdir -p /var/lib/alertmanager
    chown alertmanager:alertmanager /var/lib/alertmanager
    systemctl daemon-reload
    systemctl enable alertmanager
    systemctl start alertmanager

    # ── Install Grafana ───────────────────────────────
    cat > /etc/yum.repos.d/grafana.repo << 'GRAFANAREPO'
    [grafana]
    name=grafana
    baseurl=https://packages.grafana.com/oss/rpm
    repo_gpgcheck=1
    enabled=1
    gpgcheck=1
    gpgkey=https://packages.grafana.com/gpg.key
    GRAFANAREPO

    dnf install -y grafana

    # Configure Grafana to run on port 3001
    sed -i 's/^;http_port = 3000/http_port = 3001/' /etc/grafana/grafana.ini

    systemctl daemon-reload
    systemctl enable grafana-server
    systemctl start grafana-server

    # ── Signal completion ─────────────────────────────
    echo "Monitoring stack installation complete" > /var/log/monitoring-setup.log

  EOF

  tags = {
    Name = "${var.project_name}-monitoring"
  }
}

# ── Elastic IP for Monitoring ─────────────────────────

resource "aws_eip" "monitoring" {
  instance = aws_instance.monitoring.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-monitoring-eip"
  }

  depends_on = [aws_internet_gateway.main]
}
