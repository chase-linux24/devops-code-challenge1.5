const API_URL = process.env.REACT_APP_BACKEND_URL
  ? `${process.env.REACT_APP_BACKEND_URL}/api/`
  : 'http://localhost:8080/api/'

export default API_URL