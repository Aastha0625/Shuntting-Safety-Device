const multer = require('multer');
const path = require('path');

// Configure storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter to accept images
const fileFilter = (req, file, cb) => {
  // Flutter Web might send 'application/octet-stream' without explicit content type
  const isImageMime = file.mimetype.startsWith('image/');
  const hasImageExt = file.originalname.toLowerCase().match(/\.(jpg|jpeg|png|gif|webp)$/);
  
  if (isImageMime || hasImageExt) {
    cb(null, true);
  } else {
    cb(new Error('Not an image! Please upload only image files.'), false);
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 1024 * 1024 * 5 // 5MB max
  }
});

module.exports = upload;
