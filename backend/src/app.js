const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { rateLimit } = require('express-rate-limit');

const userRoutes = require('./routes/userRoutes');
const articleRoutes = require('./routes/articleRoutes');
const bookmarkRoutes = require('./routes/bookmarkRoutes');
const { notFound, errorHandler } = require('./middleware/errorHandler');

function createApp() {
    const app = express();

    const allowedOrigins = (process.env.CORS_ORIGIN || '')
        .split(',')
        .map((o) => o.trim())
        .filter(Boolean);
    
    app.use(helmet());
    app.use(
        cors({
            origin: allowedOrigins.length > 0 ? allowedOrigins: '*'
        })
    );
    app.use(express.json());
    app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

    app.use(
        '/api',
        rateLimit({
            windowMs: 15 * 60 * 1000,
            max: 300,
            standardHeaders: true,
            legacyHeaders: false
        })
    );

    app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

    app.use('/api/users', userRoutes);
    app.use('/api/articles', articleRoutes);
    app.use('/api/bookmarks', bookmarkRoutes);

    app.use(notFound);
    app.use(errorHandler);

    return app;
}

module.exports = createApp;