require('dotenv').config();

const createApp = require('./app');
const connectDB = require('./config/db');
const { startScheduler } = require('./services/scheduler');

const PORT = process.env.PORT || 5000;

async function start() {
    try{
        await connectDB();

        const app = createApp();

        app.listen(PORT, () => {
            console.log(`[server] NewzTable API listening on port ${PORT}`);
        });

        startScheduler();
    } catch(err) {
        console.error('[server] failed to start:', err.message);
        process.exit(1);
    }
}

start();