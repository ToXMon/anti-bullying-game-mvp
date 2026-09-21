import type { GameSettings } from '../persistence/settingsStore';
import type { ScenarioResult, ScenarioSnapshot } from '../domain/types';

interface OverlayHandlers {
  onChoice(choiceId: string): ScenarioResult;
  onReset(): ScenarioSnapshot;
  onSettingsChange(settings: GameSettings): void;
}

export class AccessibilityOverlay {
  private lastConsequence = '';

  constructor(
    private readonly root: HTMLElement,
    private readonly handlers: OverlayHandlers,
    private settings: GameSettings,
  ) {}

  render(snapshot: ScenarioSnapshot): void {
    const scene = snapshot.currentScene;
    const isEnding = snapshot.isComplete;
    const historyItems = snapshot.history
      .map((record, index) => `<li class="done">Step ${index + 1}: ${labelForTag(record.safetyTag)}</li>`)
      .join('');
    const choiceButtons = scene.choices
      .map(
        (choice, index) => `
          <button class="choice-button" type="button" data-choice-id="${escapeHtml(choice.id)}">
            <span class="choice-index" aria-hidden="true">${index + 1}</span>
            <span class="choice-copy">
              <span class="choice-label">${escapeHtml(choice.label)}</span>
              <span class="small-note">${escapeHtml(choice.description)}</span>
            </span>
          </button>`,
      )
      .join('');

    this.root.innerHTML = `
      <article class="a11y-card" aria-labelledby="scene-title">
        <p class="kicker">${isEnding ? 'Reflection ending · replay anytime' : 'No time pressure · choose when ready'}</p>
        <header class="scene-heading">
          <h1 id="scene-title" tabindex="-1">${escapeHtml(scene.title)}</h1>
          <p class="scene-meta">
            <span class="meta-chip">${escapeHtml(scene.location)}</span>
            <span aria-hidden="true">·</span>
            <span>${escapeHtml(snapshot.scenarioId)}</span>
          </p>
        </header>
        <div class="scene-text">
          <p>${escapeHtml(scene.body)}</p>
          ${scene.adultHelp ? `<p><strong>Trusted-adult note:</strong> ${escapeHtml(scene.adultHelp)}</p>` : ''}
        </div>
        ${this.lastConsequence ? `<p class="consequence" role="status"><strong>What happened:</strong> ${escapeHtml(this.lastConsequence)}</p>` : ''}
        <section aria-labelledby="prompt-title">
          <h2 id="prompt-title">${escapeHtml(scene.prompt)}</h2>
          ${scene.reflection ? `<p class="prompt">${escapeHtml(scene.reflection)}</p>` : ''}
          ${choiceButtons ? `<div class="choices">${choiceButtons}</div>` : ''}
        </section>
        ${historyItems ? `<section aria-labelledby="progress-title"><h3 id="progress-title">Your path</h3><ol class="progress-list">${historyItems}</ol></section>` : ''}
        <div class="utility-row" aria-label="Game controls">
          <button type="button" data-action="reset">${isEnding ? 'Replay from the beginning' : 'Reset safely'}</button>
          <button type="button" data-action="motion" aria-pressed="${this.settings.reducedMotion}">${this.settings.reducedMotion ? 'Use standard motion' : 'Reduce motion'}</button>
        </div>
        <p class="privacy-note"><span class="privacy-mark" aria-hidden="true">●</span><span>No names, stories, accounts, analytics, or network services are collected by this game.</span></p>
      </article>
    `;

    this.root.querySelectorAll<HTMLButtonElement>('[data-choice-id]').forEach((button) => {
      button.addEventListener('click', () => {
        const choiceId = button.dataset.choiceId;
        if (!choiceId) return;
        const result = this.handlers.onChoice(choiceId);
        this.lastConsequence = result.consequence;
        this.render(result.snapshot);
      });
    });

    this.root.querySelector<HTMLButtonElement>('[data-action="reset"]')?.addEventListener('click', () => {
      this.lastConsequence = 'The story was reset. You can replay and try another safe bystander choice.';
      this.render(this.handlers.onReset());
    });

    this.root.querySelector<HTMLButtonElement>('[data-action="motion"]')?.addEventListener('click', () => {
      this.settings = { reducedMotion: !this.settings.reducedMotion };
      this.handlers.onSettingsChange(this.settings);
      this.render(snapshot);
    });

    requestAnimationFrame(() => {
      this.root.querySelector<HTMLElement>('#scene-title')?.focus({ preventScroll: false });
    });
  }
}

function labelForTag(tag: string): string {
  switch (tag) {
    case 'supportive':
      return 'private support';
    case 'trusted-adult':
      return 'trusted-adult help';
    case 'redirect':
      return 'safe redirection';
    case 'do-nothing':
      return 'do-nothing path';
    case 'observe':
      return 'paused and observed';
    default:
      return 'repaired a choice';
  }
}

function escapeHtml(value: string): string {
  return value.replace(/[&<>'"]/g, (character) => {
    switch (character) {
      case '&':
        return '&amp;';
      case '<':
        return '&lt;';
      case '>':
        return '&gt;';
      case "'":
        return '&#39;';
      case '"':
        return '&quot;';
      default:
        return character;
    }
  });
}
