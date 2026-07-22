function notFound(req, res, next) {
    res.status(404).json({ error: `Route not found: ${req.method} ${req.originalUrl}`});
}

function errorHandler(err, req, res, next) {
    console.error('[error]', err);

    if(err.name === 'Validation Error') {
        return res.status(400).json({ error: error.message});
    }
    if(err.name === 11000 ) {
        return res.status(409).json({ error: 'Duplicate Resource', details: err.keyValue});
    }

    const status = err.status || 500;
    res.status(status).json( {
        error: status === 500 ? 'Internal Server Error' : err.message
    });
}

module.exports = { notFound, errorHandler};