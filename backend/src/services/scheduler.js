const cron = require('node-cron');
const { syncAllTopics } = require('./newsAggregatorService');

function startScheduler() {
    const intervalMinutes = parseInt(process.env.NEWS_FETCH_INTERVAL_MINUTES, 10) || 15;
    const cronExpression = `*/${intervalMinutes} * * * *`;

    console.log(`[scheduler] news sync scheduled every ${intervalMinutes} minute(s)`);

    syncAllTopics().catch((err) => {
        console.error('[scheduler] initial sync failed:', err.message)
    });

    cron.schedule(cronExpression, () => {
        syncAllTopics().catch((err) => console.error('[scheduler] sync failed: ', err.message))
    });
}

module.exports = { startScheduler };