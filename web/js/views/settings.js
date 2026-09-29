import { appViewModel } from '../viewmodels/AppViewModel.js';
import { escapeHtml } from '../utils/helpers.js';
import { saveSelectedTopics } from '../services/storageService.js';
 
function topicChipHTML(topic, vm) {
  const isSelected = vm.topics.isSelected(topic.key);
  return `
    <button class="topic-chip ${isSelected ? 'selected' : ''}"
      data-key="${escapeHtml(topic.key)}">
      <i class="bi bi-check-lg"></i>
      ${escapeHtml(topic.label)}
    </button>
  `;
}
 
function editTopicsPanelHTML(vm) {
  if (vm.topics.state === 'loading' && !vm.topics.availableTopics.length) {
    return `
      <div class="d-flex justify-content-center py-4">
        <div class="spinner-border text-primary"></div>
      </div>
    `;
  }
 
  return `
    <div class="settings-section" style="margin-top:16px">
      <div class="settings-section-label">EDIT TOPICS</div>
      <div style="padding:16px">
        <div class="topics-grid" id="settingsTopicsGrid">
          ${vm.topics.availableTopics.map((t) => topicChipHTML(t, vm)).join('')}
        </div>
        ${vm.topics.state === 'error' ? `
          <p style="color:var(--danger);font-size:13px;margin-top:8px">
            ${escapeHtml(vm.topics.errorMessage)}
          </p>
        ` : ''}
        <div style="display:flex;gap:10px;margin-top:16px">
          <button class="btn-outline" id="cancelTopicsBtn"
            style="flex:1;justify-content:center">
            Cancel
          </button>
          <button class="btn-primary" id="saveTopicsBtn"
            style="flex:1;justify-content:center"
            ${!vm.topics.hasEnoughTopics || vm.topics.state === 'loading'
              ? 'disabled' : ''}>
            ${vm.topics.state === 'loading'
              ? '<span class="spinner-border spinner-border-sm me-2"></span>'
              : ''}
            Save Topics
          </button>
        </div>
      </div>
    </div>
  `;
}
 
function confirmClearHTML() {
  return `
    <div class="settings-section"
      style="margin-top:16px;border-color:var(--danger)">
      <div class="settings-section-label" style="color:var(--danger)">
        CONFIRM RESET
      </div>
      <div style="padding:16px">
        <p style="font-size:14px;color:var(--text-secondary);margin-bottom:16px">
          This will reset the app to its initial state.
          Your bookmarks and topic preferences will be lost.
        </p>
        <div style="display:flex;gap:10px">
          <button class="btn-outline" id="cancelClearBtn"
            style="flex:1;justify-content:center">
            Cancel
          </button>
          <button class="btn-primary" id="confirmClearBtn"
            style="flex:1;justify-content:center;
              background:var(--danger)">
            <i class="bi bi-trash"></i> Clear Data
          </button>
        </div>
      </div>
    </div>
  `;
}
 
function renderSettings(vm) {
  const container = document.getElementById('page-settings');
  if (!container) return;
 
  container.innerHTML = `
    <div class="page-inner">
      <div class="page-header">
        <h1 class="page-title">Settings</h1>
      </div>
 
      <div class="settings-section">
        <div class="settings-section-label">PREFERENCES</div>
 
        <div class="settings-item" id="darkModeItem">
          <div class="settings-item-left">
            <div class="settings-item-icon">
              <i class="bi bi-${vm.isDarkMode ? 'moon-fill' : 'sun-fill'}"></i>
            </div>
            <div>
              <div class="settings-item-title">Dark Mode</div>
              <div class="settings-item-subtitle">Switch to dark theme</div>
            </div>
          </div>
          <div class="toggle-switch">
            <input type="checkbox" id="darkModeToggle"
              ${vm.isDarkMode ? 'checked' : ''} />
            <label for="darkModeToggle"></label>
          </div>
        </div>
      </div>
 
      <div class="settings-section">
        <div class="settings-section-label">CONTENT</div>
 
        <div class="settings-item" id="editTopicsItem">
          <div class="settings-item-left">
            <div class="settings-item-icon">
              <i class="bi bi-tags-fill"></i>
            </div>
            <div>
              <div class="settings-item-title">Edit Topics</div>
              <div class="settings-item-subtitle">
                Change your personalised topics
              </div>
            </div>
          </div>
          <i class="bi bi-chevron-right"
            style="color:var(--text-muted)"></i>
        </div>
      </div>
 
      <div class="settings-section">
        <div class="settings-section-label">ABOUT</div>
 
        <div class="settings-item" style="cursor:default">
          <div class="settings-item-left">
            <div class="settings-item-icon">
              <i class="bi bi-fingerprint"></i>
            </div>
            <div>
              <div class="settings-item-title">Device ID</div>
              <div class="device-id">${escapeHtml(vm.deviceId)}</div>
            </div>
          </div>
        </div>
 
        <div class="settings-item" style="cursor:default">
          <div class="settings-item-left">
            <div class="settings-item-icon">
              <i class="bi bi-info-circle-fill"></i>
            </div>
            <div>
              <div class="settings-item-title">Version</div>
              <div class="settings-item-subtitle">1.0.0</div>
            </div>
          </div>
        </div>
      </div>
 
      <div class="settings-section">
        <div class="settings-section-label">DATA</div>
 
        <div class="settings-item" id="clearDataItem">
          <div class="settings-item-left">
            <div class="settings-item-icon danger">
              <i class="bi bi-trash-fill"></i>
            </div>
            <div>
              <div class="settings-item-title"
                style="color:var(--danger)">
                Clear Local Data
              </div>
              <div class="settings-item-subtitle">
                Reset app to initial state
              </div>
            </div>
          </div>
          <i class="bi bi-chevron-right"
            style="color:var(--text-muted)"></i>
        </div>
      </div>
 
      <div id="editTopicsPanel"></div>
      <div id="confirmClearPanel"></div>
    </div>
  `;
 
  attachSettingsEvents();
}
 
function attachSettingsEvents() {
  const vm = appViewModel;
 
  document.getElementById('darkModeToggle')?.addEventListener('change', () => {
    vm.toggleDarkMode();
  });
 
  document.getElementById('darkModeItem')?.addEventListener('click', (e) => {
    if (e.target.id !== 'darkModeToggle' &&
        e.target.tagName !== 'LABEL') {
      vm.toggleDarkMode();
    }
  });
 
  document.getElementById('editTopicsItem')?.addEventListener('click', async () => {
    const panel = document.getElementById('editTopicsPanel');
    panel.innerHTML = editTopicsPanelHTML(vm);
 
    await vm.topics.fetchTopics();
    const { getSelectedTopics } = await import('../services/storageService.js');
    vm.topics.loadSavedTopics(getSelectedTopics());
 
    panel.innerHTML = editTopicsPanelHTML(vm);
    attachTopicsEvents();
  });
 
  document.getElementById('clearDataItem')?.addEventListener('click', () => {
    const panel = document.getElementById('confirmClearPanel');
    panel.innerHTML = confirmClearHTML();
    attachClearEvents();
  });
}
 
function attachTopicsEvents() {
  const vm = appViewModel;
 
  document.getElementById('settingsTopicsGrid')?.addEventListener('click', (e) => {
    const chip = e.target.closest('.topic-chip');
    if (!chip) return;
    vm.topics.toggleTopic(chip.dataset.key);
    const panel = document.getElementById('editTopicsPanel');
    panel.innerHTML = editTopicsPanelHTML(vm);
    attachTopicsEvents();
  });
 
  document.getElementById('cancelTopicsBtn')?.addEventListener('click', () => {
    document.getElementById('editTopicsPanel').innerHTML = '';
  });
 
  document.getElementById('saveTopicsBtn')?.addEventListener('click', async () => {
    const success = await vm.topics.saveTopics();
    if (success) {
      saveSelectedTopics(vm.topics.selectedKeys);
      document.getElementById('editTopicsPanel').innerHTML = '';
      await vm.feed.fetchFeed(true);
    }
  });
}
 
function attachClearEvents() {
  const vm = appViewModel;
 
  document.getElementById('cancelClearBtn')?.addEventListener('click', () => {
    document.getElementById('confirmClearPanel').innerHTML = '';
  });
 
  document.getElementById('confirmClearBtn')?.addEventListener('click', async () => {
    await vm.clearLocalData();
    window.location.reload();
  });
}
 
export function initSettings() {
  const vm = appViewModel;
  const unsubscribe = vm.subscribe(() => renderSettings(vm));
  renderSettings(vm);
  return unsubscribe;
}