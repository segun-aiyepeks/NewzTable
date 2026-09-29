import { appViewModel } from './viewmodels/AppViewModel.js';
import { initOnboarding } from './views/onboarding.js';
import { renderApp } from './views/app.js';
import { show, hide } from './utils/helpers.js';
 
async function boot() {
  await appViewModel.initialize();
 
  if (appViewModel.isOnboarded) {
    show(document.getElementById('app'));
    renderApp();
  } else {
    await initOnboarding();
  }
}
 
boot().catch((err) => {
  console.error('[NewzTable] boot failed:', err);
  document.body.innerHTML = `
    <div style="display:flex;flex-direction:column;align-items:center;
      justify-content:center;height:100vh;gap:16px;font-family:Inter,sans-serif;
      padding:32px;text-align:center">
      <svg width="48" height="48" fill="none" viewBox="0 0 24 24"
        stroke="#ea4335" stroke-width="2">
        <circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="8" x2="12" y2="12"/>
        <line x1="12" y1="16" x2="12.01" y2="16"/>
      </svg>
      <h2 style="font-size:20px;font-weight:700;color:#202124">
        Failed to start NewzTable
      </h2>
      <p style="color:#5f6368;font-size:14px">
        ${err.message}
      </p>
      <button onclick="window.location.reload()"
        style="padding:10px 24px;background:#1a73e8;color:#fff;
          border:none;border-radius:999px;font-size:14px;
          font-weight:600;cursor:pointer">
        Retry
      </button>
    </div>
  `;
});