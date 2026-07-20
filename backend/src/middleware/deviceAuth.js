const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function requireDeviceId(req, res, next) {
    const deviceId = req.header('X-Device-Id');

    if (!deviceId) {
        return res.status(401).json({ error: 'Missing X-Device-Id header' });
    }
    if (!UUID_RE.test(deviceId)) {
        return res.status(400).json({ error: 'X-Device-Id must be a valid UUID'});
    }

    req.deviceId = deviceId;
    next();
}

module.exports = { requireDeviceId};