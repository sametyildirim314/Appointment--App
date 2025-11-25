const jwt = require('jsonwebtoken');

// JWT token doğrulama middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token bulunamadı'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your_super_secret_jwt_key', (err, user) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Geçersiz token'
      });
    }
    req.user = user;
    next();
  });
};

// Token oluştur
const generateToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET || 'your_super_secret_jwt_key', {
    expiresIn: '30d' // 30 gün geçerli
  });
};

module.exports = {
  authenticateToken,
  generateToken
};

