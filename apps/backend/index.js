const express = require('express')
const { v4: uuidv4 } = require('uuid')
const client = require('prom-client')
const { CORS_ORIGIN, PORT, NODE_ENV } = require('./config')

// ── Prometheus Setup ──────────────────────────────────

const collectDefaultMetrics = client.collectDefaultMetrics
collectDefaultMetrics({ prefix: 'devops_challenge_' })

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
})

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5]
})

// ── Express Setup ─────────────────────────────────────

const ID = uuidv4()
const app = express()
app.use(express.json())

// ── CORS Middleware ───────────────────────────────────

app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', CORS_ORIGIN)
  res.setHeader('Access-Control-Allow-Methods', 'GET')
  res.setHeader('Access-Control-Allow-Headers', '*')
  next()
})

// ── Prometheus Middleware ─────────────────────────────

app.use((req, res, next) => {
  if (req.path === '/metrics') return next()

  const start = Date.now()
  const originalEnd = res.end

  res.end = function(...args) {
    const duration = (Date.now() - start) / 1000
    const route = req.path || '/'
    const method = req.method
    const statusCode = res.statusCode.toString()

    httpRequestsTotal.labels(method, route, statusCode).inc()
    httpRequestDuration.labels(method, route, statusCode).observe(duration)

    originalEnd.apply(this, args)
  }

  next()
})

// ── Routes ────────────────────────────────────────────

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    environment: NODE_ENV,
    timestamp: new Date().toISOString()
  })
})

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType)
  res.end(await client.register.metrics())
})

app.get(/.*/, (req, res) => {
  console.log(`${new Date().toISOString()} GET ${req.path}`)
  res.json({ id: ID })
})

// ── Start Server ──────────────────────────────────────

app.listen(PORT, () => {
  console.log(`Backend started on port ${PORT} in ${NODE_ENV} mode`)
  console.log(`Metrics available at http://localhost:${PORT}/metrics`)
})