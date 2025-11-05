const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(express.json());
app.use(morgan('combined'));

// Mock data
const users = [
  { id: 1, name: 'John Doe', email: 'john@example.com', tier: 'premium' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', tier: 'basic' },
  { id: 3, name: 'Bob Johnson', email: 'bob@example.com', tier: 'premium' }
];

const products = [
  { id: 1, name: 'Product A', price: 99.99, category: 'Electronics' },
  { id: 2, name: 'Product B', price: 149.99, category: 'Clothing' },
  { id: 3, name: 'Product C', price: 79.99, category: 'Books' }
];

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Users endpoints
app.get('/api/v1/users', (req, res) => {
  console.log('Request headers:', req.headers);
  res.json({
    success: true,
    data: users,
    count: users.length,
    consumer: req.headers['x-consumer-username'] || 'unknown'
  });
});

app.get('/api/v1/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) {
    return res.status(404).json({ success: false, error: 'User not found' });
  }
  res.json({ success: true, data: user });
});

app.post('/api/v1/users', (req, res) => {
  const newUser = {
    id: users.length + 1,
    name: req.body.name || 'New User',
    email: req.body.email || 'user@example.com',
    tier: req.body.tier || 'basic'
  };
  users.push(newUser);
  res.status(201).json({ success: true, data: newUser });
});

// Products endpoints
app.get('/api/v1/products', (req, res) => {
  const { category, minPrice, maxPrice } = req.query;
  let filtered = products;

  if (category) {
    filtered = filtered.filter(p => p.category === category);
  }
  if (minPrice) {
    filtered = filtered.filter(p => p.price >= parseFloat(minPrice));
  }
  if (maxPrice) {
    filtered = filtered.filter(p => p.price <= parseFloat(maxPrice));
  }

  res.json({
    success: true,
    data: filtered,
    count: filtered.length,
    consumer: req.headers['x-consumer-username'] || 'unknown'
  });
});

app.get('/api/v1/products/:id', (req, res) => {
  const product = products.find(p => p.id === parseInt(req.params.id));
  if (!product) {
    return res.status(404).json({ success: false, error: 'Product not found' });
  }
  res.json({ success: true, data: product });
});

app.post('/api/v1/products', (req, res) => {
  const newProduct = {
    id: products.length + 1,
    name: req.body.name || 'New Product',
    price: req.body.price || 0,
    category: req.body.category || 'General'
  };
  products.push(newProduct);
  res.status(201).json({ success: true, data: newProduct });
});

// Statistics endpoint
app.get('/api/v1/stats', (req, res) => {
  res.json({
    success: true,
    data: {
      totalUsers: users.length,
      totalProducts: products.length,
      timestamp: new Date().toISOString(),
      server: 'demo-api-v1'
    }
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: err.message
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Demo API server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});

module.exports = app;
