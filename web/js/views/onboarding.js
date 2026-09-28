import { appViewModel } from '../viewmodels/AppViewModel';
import { escapeHtml, show, hide } from '../utils/helpers';
import { saveSelectedTopics } from '../services/storageService';

function renderTopicChip(topic, vm) {
    const isSelected = vm.topics.isSelected(topic.key);
    return `
        <button class="topic-chip ${isSelected ? 'selected' : ''}" data-key="${escapeHtml(topic.key)}">
            <i class="bi bi-check-lg"></i>
            ${escapeHtml(topic.label)}
        </button>
    `;
}

function renderButton(vm) {
    const disabled = !vm.topics.hasEnoughTopics || vm.topics.state === 'loading';
    const label = vm.topics.state === 'loading' ? '<span class="spinner-border spinner-border-sm me-2"></span>Setting up...' : vm.topics.selectedCount === 0 ? 'Select at least 3 topics' : `${vm.topics.selectedCount} selected &mdash; Continue`;

    return `
        <button id="onboardingBtn" class="btn-primary w-100" style="justify-content:center; padding:14px 24px; font-size:16px; border-radius:12px" ${disabled ? 'disabled' : ''}>
            ${label}
        </button>
    `;
}

export function renderOnboarding() {
    const container = document.getElementById('onboarding');
    if(!container) return;

    const vm =appViewModel;
    
    container.innerHTML = `
        <div class="onboarding-wrap">
            <div class="onboarding-card">
                <div class="onboarding-logo">
                    Newz<span style="color:var(--primary)">Table</span>
                <div>
                <h1 class="onboarding-title">What are you interested in?</h1>
                <p class="onboarding-subtitle">Pick at least 3 topics to personalize your feed.</p>

                ${vm.topics.state === 'loading' && vm.topics.availableTopics.length === 0 ? `
                <div class="d-flex justify-content-center py-5">
                    <div class="spinner-border text-primary"></div>
                </div> `:
                vm.topics.state === 'error' && vm.topics.availableTopics.length === 0 ? `
                <div class="state-view">
                    <div class="state-icon danger">
                        <i class="bi bi-wifi-off"></i>
                    </div>
                    <p class="state-title">Could not load topics</p>
                    <p class="state-message">${escapeHtml(vm.topics.errorMessage)}</p>
                    <button class="btn-primary" id="retryTopics">
                        <i class="bi bi-arrow-clockwise"></i> Try Again
                    </button>
                </div>
                ` : `
                <div class="topics-grid" id="topicsGrid">
                    ${vm.topics.availableTopics.map((t)=> renderTopic(t, vm)).join('')}
                </div>

                ${vm.topic.state === 'error'? `
                    <p style="color:var(--danger);font-size:13px;text-align:center;margin-bottom:12px">
                        ${escapeHtml(vm.topics.errorMessage)}
                    </p> ` : ''
                }
                ${renderButton(vm)}
            `}
            </div>
        </div>
    `;
    attachOnboardingEvents();
}

function attachOnboardingEvents() {
    const vm = appViewModel;

    document.getElementById('topicsGrid')?.addEventListener('click', (e) => {
        const chip = e.target.closest(`.topic-chip`);
        if(!chip) return;
        vm.topics.toggleTopic(chip.dataset.key);
    });
    document.getElementById('onboardingBtn')?.addEventListener('click', async () => {
        const success = await vm.topics.initUser(vm.deviceId);
        if(success) {
            saveSelectedTopics(vm.topics.selectedKeys);
            await vm.completeOnboarding(vm.topics.selectedKeys);

            hide(document.getElementById('onboarding'));
            show(document.getElementById('app'));

            const { renderApp } = await import('./app.js');
            renderApp();
        }
    });

    document.getElementById('retryTopics')?.addEventListener('click', ()=> {
        vm.topics.fetchTopics();
    });
}

export async function initOnboarding() {
    const vm = appViewModel;
    await vm.topics.fetchTopics();

    const unsubscribe = vm.topics.subscribe(() => {
        renderOnboarding();
    });

    renderOnboarding();
    show(document.getElementById('onboarding'));

    return unsubscribe;
}