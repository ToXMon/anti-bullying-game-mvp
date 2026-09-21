import Phaser from 'phaser';
import type { GameSettings } from '../persistence/settingsStore';
import type { ScenarioContent, ScenarioSnapshot } from '../domain/types';
import { buildPresentation, type ScenePresentation } from './presentationState';

export const GAME_READY_EVENT = 'game:ready';
export const SCENE_UPDATED_EVENT = 'scenario:snapshot';
export const SETTINGS_UPDATED_EVENT = 'settings:changed';

const FONT_STACK = 'Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif';

export class GameScene extends Phaser.Scene {
  private currentSnapshot?: ScenarioSnapshot;
  private currentSettings: GameSettings = { reducedMotion: false };
  private worldLayer?: Phaser.GameObjects.Graphics;
  private atmosphereLayer?: Phaser.GameObjects.Graphics;
  private peopleLayer?: Phaser.GameObjects.Graphics;
  private foregroundLayer?: Phaser.GameObjects.Graphics;
  private panelLayer?: Phaser.GameObjects.Graphics;
  private titleText?: Phaser.GameObjects.Text;
  private bodyText?: Phaser.GameObjects.Text;
  private hudText?: Phaser.GameObjects.Text;
  private stateText?: Phaser.GameObjects.Text;
  private focusText?: Phaser.GameObjects.Text;
  private progressText?: Phaser.GameObjects.Text;
  private floatingAccents: Phaser.GameObjects.Arc[] = [];
  private previousSceneId?: string;

  constructor(private readonly scenario: ScenarioContent) {
    super('game');
  }

  preload(): void {
    // The visual upgrade uses original procedural Phaser graphics and CSS only.
    // No third-party art or network-hosted assets are loaded at runtime.
  }

  create(): void {
    this.cameras.main.setBackgroundColor('#0b1020');

    this.worldLayer = this.add.graphics().setDepth(0);
    this.atmosphereLayer = this.add.graphics().setDepth(2);
    this.peopleLayer = this.add.graphics().setDepth(3);
    this.foregroundLayer = this.add.graphics().setDepth(4);
    this.panelLayer = this.add.graphics().setDepth(5);

    this.titleText = this.add.text(0, 0, '', textStyle(30, '#0f172a', 800)).setDepth(6);
    this.bodyText = this.add.text(0, 0, '', textStyle(17, '#24324a', 500)).setDepth(6);
    this.hudText = this.add.text(0, 0, '', textStyle(15, '#eff6ff', 800)).setDepth(6);
    this.stateText = this.add.text(0, 0, '', textStyle(14, '#0f172a', 900)).setDepth(6);
    this.focusText = this.add.text(0, 0, '', textStyle(16, '#eff6ff', 700)).setDepth(6);
    this.progressText = this.add.text(0, 0, '', textStyle(13, '#eff6ff', 800)).setDepth(6);

    this.createFloatingAccents();
    this.scale.on('resize', this.handleResize, this);

    this.game.events.on(SCENE_UPDATED_EVENT, (snapshot: ScenarioSnapshot) => {
      this.currentSnapshot = snapshot;
      this.redrawSnapshot(true);
    });

    this.game.events.on(SETTINGS_UPDATED_EVENT, (settings: GameSettings) => {
      this.currentSettings = settings;
      this.redrawSnapshot(false);
    });

    this.game.events.emit(GAME_READY_EVENT);

    if (this.currentSnapshot) {
      this.redrawSnapshot(false);
    }
  }

  private handleResize(): void {
    this.redrawSnapshot(false);
  }

  private redrawSnapshot(allowTransition: boolean): void {
    if (!this.currentSnapshot || !this.worldLayer || !this.panelLayer || !this.titleText || !this.bodyText) return;

    const sceneId = this.currentSnapshot.currentScene.id;
    const shouldTransition =
      allowTransition && !this.currentSettings.reducedMotion && Boolean(this.previousSceneId) && this.previousSceneId !== sceneId;

    const draw = () => {
      if (!this.currentSnapshot) return;
      const presentation = buildPresentation(this.currentSnapshot, this.scenario);
      this.drawCinematicWorld(presentation);
      this.drawInterface(presentation);
      this.positionFloatingAccents(presentation);
      this.previousSceneId = sceneId;
    };

    if (shouldTransition) {
      this.cameras.main.fadeOut(110, 11, 16, 32);
      this.time.delayedCall(95, () => {
        draw();
        this.cameras.main.fadeIn(180, 11, 16, 32);
      });
    } else {
      draw();
    }
  }

  private drawCinematicWorld(presentation: ScenePresentation): void {
    if (!this.currentSnapshot || !this.worldLayer || !this.atmosphereLayer || !this.peopleLayer || !this.foregroundLayer) return;

    const { width, height } = this.scale;
    const tone = presentation.tone;
    const scene = this.currentSnapshot.currentScene;
    const horizonY = height * 0.46;
    const vanishingX = width * 0.52;

    const world = this.worldLayer;
    const atmosphere = this.atmosphereLayer;
    const people = this.peopleLayer;
    const foreground = this.foregroundLayer;

    world.clear();
    atmosphere.clear();
    people.clear();
    foreground.clear();

    world.fillGradientStyle(tone.skyTop, tone.skyTop, tone.skyBottom, tone.skyBottom, 1, 1, 1, 1);
    world.fillRect(0, 0, width, height);

    this.drawSoftGlow(world, width * 0.78, height * 0.2, Math.min(width, height) * 0.22, tone.glow, 0.34);
    this.drawDistantSchool(world, width, height, horizonY, tone);
    this.drawCourtyardPerspective(world, width, height, horizonY, vanishingX, tone);
    this.drawSceneProps(world, width, height, presentation);
    this.drawAtmosphere(atmosphere, width, height, horizonY, tone);
    this.drawCharacters(people, width, height, presentation);
    this.drawForegroundPlates(foreground, width, height, tone);

    const progressWidth = Math.max(120, width * 0.24);
    world.fillStyle(0xffffff, 0.18);
    world.fillRoundedRect(28, 28, progressWidth, 9, 6);
    world.fillStyle(tone.glow, 0.96);
    world.fillRoundedRect(28, 28, progressWidth * presentation.progressPercent, 9, 6);

    if (presentation.isTrustedAdult) {
      this.drawSoftGlow(atmosphere, width * 0.22, height * 0.34, Math.min(width, height) * 0.18, tone.glow, 0.24);
    }
  }

  private drawDistantSchool(
    graphics: Phaser.GameObjects.Graphics,
    width: number,
    height: number,
    horizonY: number,
    tone: ScenePresentation['tone'],
  ): void {
    const buildingY = horizonY - height * 0.18;
    const buildingW = width * 0.66;
    const buildingH = height * 0.24;
    const buildingX = width * 0.5 - buildingW / 2;

    graphics.fillStyle(tone.horizon, 0.72);
    graphics.fillRoundedRect(buildingX, buildingY, buildingW, buildingH, 22);
    graphics.fillStyle(0xffffff, 0.42);
    graphics.fillRoundedRect(buildingX + buildingW * 0.06, buildingY + buildingH * 0.18, buildingW * 0.88, buildingH * 0.68, 16);

    graphics.fillStyle(tone.accent, 0.18);
    for (let index = 0; index < 7; index += 1) {
      const x = buildingX + buildingW * (0.12 + index * 0.12);
      graphics.fillRoundedRect(x, buildingY + buildingH * 0.28, buildingW * 0.065, buildingH * 0.22, 8);
      graphics.fillRoundedRect(x, buildingY + buildingH * 0.6, buildingW * 0.065, buildingH * 0.18, 8);
    }

    graphics.fillStyle(0xffffff, 0.34);
    this.fillTrapezoid(graphics, buildingX - width * 0.04, buildingY + buildingH * 0.1, buildingX + buildingW + width * 0.04, buildingY + buildingH * 0.1, buildingX + buildingW * 0.9, buildingY - height * 0.02, buildingX + buildingW * 0.1, buildingY - height * 0.02);
  }

  private drawCourtyardPerspective(
    graphics: Phaser.GameObjects.Graphics,
    width: number,
    height: number,
    horizonY: number,
    vanishingX: number,
    tone: ScenePresentation['tone'],
  ): void {
    graphics.fillStyle(tone.ground, 0.88);
    graphics.fillRect(0, horizonY, width, height - horizonY);

    graphics.fillStyle(0xf7e6c8, 0.92);
    this.fillTrapezoid(graphics, width * 0.18, height, width * 0.86, height, vanishingX + width * 0.08, horizonY + 10, vanishingX - width * 0.08, horizonY + 10);

    graphics.lineStyle(2, 0xffffff, 0.28);
    for (let index = 0; index < 7; index += 1) {
      const offset = (index - 3) * width * 0.08;
      graphics.lineBetween(vanishingX, horizonY + 12, width * 0.52 + offset, height);
    }

    graphics.lineStyle(2, tone.shadow, 0.08);
    for (let index = 0; index < 8; index += 1) {
      const y = horizonY + 20 + index * ((height - horizonY) / 8);
      const span = (y - horizonY) / (height - horizonY);
      graphics.lineBetween(width * (0.32 - span * 0.14), y, width * (0.68 + span * 0.14), y);
    }
  }

  private drawSceneProps(
    graphics: Phaser.GameObjects.Graphics,
    width: number,
    height: number,
    presentation: ScenePresentation,
  ): void {
    const tone = presentation.tone;
    const tableY = height * 0.61;

    graphics.fillStyle(0x14532d, 0.32);
    graphics.fillEllipse(width * 0.15, height * 0.71, width * 0.27, height * 0.08);
    graphics.fillStyle(0x7c4a24, 0.95);
    graphics.fillRoundedRect(width * 0.06, height * 0.62, width * 0.2, height * 0.075, 16);
    graphics.fillStyle(0x7dd3fc, 0.8);
    graphics.fillEllipse(width * 0.11, height * 0.59, width * 0.1, height * 0.08);
    graphics.fillStyle(0x86efac, 0.86);
    graphics.fillEllipse(width * 0.2, height * 0.58, width * 0.09, height * 0.07);

    graphics.fillStyle(0x8b5e34, 0.94);
    graphics.fillRoundedRect(width * 0.64, tableY, width * 0.22, height * 0.035, 12);
    graphics.fillStyle(0x6b4423, 0.82);
    graphics.fillRoundedRect(width * 0.665, tableY + height * 0.035, width * 0.025, height * 0.12, 6);
    graphics.fillRoundedRect(width * 0.81, tableY + height * 0.035, width * 0.025, height * 0.12, 6);

    graphics.fillStyle(tone.accentAlt, 0.9);
    graphics.fillRoundedRect(width * 0.69, tableY - height * 0.035, width * 0.06, height * 0.03, 8);
    graphics.fillStyle(0xffffff, 0.96);
    graphics.fillRoundedRect(width * 0.76, tableY - height * 0.026, width * 0.075, height * 0.022, 5);

    if (presentation.mood === 'redirect') {
      graphics.fillStyle(0xffffff, 0.72);
      graphics.fillRoundedRect(width * 0.56, tableY - height * 0.1, width * 0.16, height * 0.052, 14);
      graphics.lineStyle(3, tone.accent, 0.74);
      graphics.lineBetween(width * 0.575, tableY - height * 0.074, width * 0.7, tableY - height * 0.074);
    }

    if (presentation.mood === 'observe' || presentation.mood === 'ending-do-nothing') {
      graphics.fillStyle(0x334155, 0.28);
      graphics.fillRoundedRect(width * 0.4, height * 0.66, width * 0.24, height * 0.04, 14);
      graphics.fillRoundedRect(width * 0.43, height * 0.7, width * 0.025, height * 0.11, 6);
      graphics.fillRoundedRect(width * 0.59, height * 0.7, width * 0.025, height * 0.11, 6);
    }
  }

  private drawAtmosphere(
    graphics: Phaser.GameObjects.Graphics,
    width: number,
    height: number,
    horizonY: number,
    tone: ScenePresentation['tone'],
  ): void {
    graphics.fillStyle(0xffffff, 0.2);
    graphics.fillRoundedRect(width * 0.04, horizonY - height * 0.08, width * 0.5, height * 0.09, 36);
    graphics.fillRoundedRect(width * 0.32, horizonY + height * 0.03, width * 0.62, height * 0.075, 34);
    graphics.fillStyle(tone.glow, 0.14);
    graphics.fillRoundedRect(width * 0.12, horizonY + height * 0.12, width * 0.74, height * 0.095, 42);
  }

  private drawCharacters(
    graphics: Phaser.GameObjects.Graphics,
    width: number,
    height: number,
    presentation: ScenePresentation,
  ): void {
    const tone = presentation.tone;
    const baseY = height * 0.66;

    if (presentation.mood === 'trusted-adult') {
      this.drawSoftGlow(graphics, width * 0.29, baseY - height * 0.08, Math.min(width, height) * 0.15, tone.glow, 0.18);
      this.drawAvatar(graphics, width * 0.27, baseY, 1.15, 0x4f46e5, 0xf8c8a7, 0x4b2e20, 'teacher');
      this.drawAvatar(graphics, width * 0.43, baseY + height * 0.035, 0.86, 0x0f9f75, 0xf4bf96, 0x38251b, 'calm');
      this.drawAvatar(graphics, width * 0.57, baseY + height * 0.03, 0.83, 0x2563eb, 0xd9a577, 0x281b14, 'calm');
      return;
    }

    if (presentation.mood === 'supportive' || presentation.mood === 'ending-positive') {
      this.drawSoftGlow(graphics, width * 0.46, baseY - height * 0.07, Math.min(width, height) * 0.18, tone.glow, 0.17);
      this.drawAvatar(graphics, width * 0.42, baseY + height * 0.02, 0.9, 0x0f9f75, 0xf4bf96, 0x38251b, 'calm');
      this.drawAvatar(graphics, width * 0.53, baseY, 0.9, 0x2563eb, 0xd9a577, 0x281b14, 'happy');
      this.drawAvatar(graphics, width * 0.68, baseY + height * 0.04, 0.76, 0xf59e0b, 0xf8c8a7, 0x4b2e20, 'happy');
      return;
    }

    if (presentation.mood === 'redirect') {
      this.drawAvatar(graphics, width * 0.56, baseY + height * 0.01, 0.86, 0x14b8a6, 0xf4bf96, 0x38251b, 'happy');
      this.drawAvatar(graphics, width * 0.66, baseY + height * 0.035, 0.78, 0xea8a1a, 0xd9a577, 0x281b14, 'happy');
      this.drawAvatar(graphics, width * 0.77, baseY + height * 0.018, 0.74, 0x2563eb, 0xf8c8a7, 0x4b2e20, 'calm');
      return;
    }

    if (presentation.mood === 'observe' || presentation.mood === 'ending-do-nothing') {
      this.drawAvatar(graphics, width * 0.45, baseY + height * 0.04, 0.82, 0x64748b, 0xf4bf96, 0x38251b, 'quiet');
      this.drawAvatar(graphics, width * 0.71, baseY + height * 0.01, 0.72, 0x94a3b8, 0xd9a577, 0x281b14, 'neutral');
      this.drawAvatar(graphics, width * 0.8, baseY + height * 0.02, 0.7, 0x94a3b8, 0xf8c8a7, 0x4b2e20, 'neutral');
      return;
    }

    if (presentation.mood === 'repair') {
      this.drawAvatar(graphics, width * 0.48, baseY + height * 0.02, 0.86, 0xa855f7, 0xf4bf96, 0x38251b, 'calm');
      this.drawAvatar(graphics, width * 0.64, baseY, 0.82, 0xf97316, 0xd9a577, 0x281b14, 'neutral');
      this.drawAvatar(graphics, width * 0.74, baseY + height * 0.03, 0.76, 0x60a5fa, 0xf8c8a7, 0x4b2e20, 'neutral');
      return;
    }

    this.drawSoftGlow(graphics, width * 0.48, baseY - height * 0.08, Math.min(width, height) * 0.17, tone.glow, 0.15);
    this.drawAvatar(graphics, width * 0.4, baseY + height * 0.035, 0.84, 0x0f9f75, 0xf4bf96, 0x38251b, 'quiet');
    this.drawAvatar(graphics, width * 0.62, baseY, 0.78, 0x2563eb, 0xd9a577, 0x281b14, 'neutral');
    this.drawAvatar(graphics, width * 0.72, baseY + height * 0.015, 0.74, 0xf59e0b, 0xf8c8a7, 0x4b2e20, 'neutral');
    this.drawAvatar(graphics, width * 0.81, baseY + height * 0.035, 0.7, 0x7c3aed, 0xf4bf96, 0x281b14, 'neutral');
  }

  private drawAvatar(
    graphics: Phaser.GameObjects.Graphics,
    x: number,
    y: number,
    scale: number,
    bodyColor: number,
    skinColor: number,
    hairColor: number,
    expression: 'happy' | 'calm' | 'neutral' | 'quiet' | 'teacher',
  ): void {
    const bodyW = 42 * scale;
    const bodyH = 58 * scale;
    const headR = 18 * scale;

    graphics.fillStyle(0x0f172a, 0.13);
    graphics.fillEllipse(x, y + bodyH * 0.74, bodyW * 1.18, bodyH * 0.24);
    graphics.fillStyle(bodyColor, 0.96);
    graphics.fillRoundedRect(x - bodyW / 2, y - bodyH * 0.2, bodyW, bodyH, 16 * scale);
    graphics.fillStyle(0xffffff, 0.28);
    graphics.fillRoundedRect(x - bodyW * 0.28, y - bodyH * 0.05, bodyW * 0.18, bodyH * 0.46, 7 * scale);
    graphics.fillStyle(skinColor, 1);
    graphics.fillCircle(x, y - bodyH * 0.36, headR);
    graphics.fillStyle(hairColor, 0.94);
    graphics.fillEllipse(x - headR * 0.12, y - bodyH * 0.49, headR * 1.55, headR * 0.86);
    graphics.fillCircle(x - headR * 0.72, y - bodyH * 0.38, headR * 0.42);
    graphics.fillStyle(0x172033, 0.88);
    graphics.fillCircle(x - headR * 0.38, y - bodyH * 0.36, 2.3 * scale);
    graphics.fillCircle(x + headR * 0.38, y - bodyH * 0.36, 2.3 * scale);
    graphics.lineStyle(2 * scale, 0x172033, 0.76);
    const smileY = y - bodyH * 0.27;
    if (expression === 'quiet') {
      graphics.lineBetween(x - headR * 0.28, smileY, x + headR * 0.28, smileY);
    } else if (expression === 'neutral') {
      graphics.lineBetween(x - headR * 0.22, smileY + 1 * scale, x + headR * 0.22, smileY + 1 * scale);
    } else {
      graphics.beginPath();
      graphics.arc(x, smileY - 1 * scale, headR * 0.32, 0.15, Math.PI - 0.15, false);
      graphics.strokePath();
    }

    if (expression === 'teacher') {
      graphics.lineStyle(3 * scale, 0xfff3b0, 0.9);
      graphics.lineBetween(x - bodyW * 0.5, y - bodyH * 0.02, x - bodyW * 0.76, y - bodyH * 0.24);
      graphics.lineBetween(x + bodyW * 0.5, y - bodyH * 0.02, x + bodyW * 0.76, y - bodyH * 0.24);
    }
  }

  private drawForegroundPlates(
    graphics: Phaser.GameObjects.Graphics,
    width: number,
    height: number,
    tone: ScenePresentation['tone'],
  ): void {
    graphics.fillStyle(tone.shadow, 0.18);
    graphics.fillEllipse(width * -0.02, height * 0.18, width * 0.22, height * 0.45);
    graphics.fillEllipse(width * 1.02, height * 0.25, width * 0.18, height * 0.5);
    graphics.fillStyle(0xffffff, 0.14);
    graphics.fillCircle(width * 0.1, height * 0.12, Math.min(width, height) * 0.05);
    graphics.fillCircle(width * 0.94, height * 0.12, Math.min(width, height) * 0.04);
    graphics.lineStyle(2, 0xffffff, 0.14);
    graphics.strokeRoundedRect(18, 18, width - 36, height - 36, 28);
  }

  private drawInterface(presentation: ScenePresentation): void {
    if (
      !this.currentSnapshot ||
      !this.panelLayer ||
      !this.titleText ||
      !this.bodyText ||
      !this.hudText ||
      !this.stateText ||
      !this.focusText ||
      !this.progressText
    ) {
      return;
    }

    const { width, height } = this.scale;
    const scene = this.currentSnapshot.currentScene;
    const compact = width < 680 || height < 560;
    const margin = compact ? 18 : 28;
    const panelW = width - margin * 2;
    const panelH = clamp(height * (compact ? 0.38 : 0.3), compact ? 190 : 176, compact ? 260 : 230);
    const panelX = margin;
    const panelY = height - panelH - margin;
    const tone = presentation.tone;

    const panel = this.panelLayer;
    panel.clear();
    panel.fillStyle(0xffffff, 0.9);
    panel.fillRoundedRect(panelX, panelY, panelW, panelH, 26);
    panel.lineStyle(3, tone.accent, 0.42);
    panel.strokeRoundedRect(panelX, panelY, panelW, panelH, 26);
    panel.fillStyle(tone.glow, 0.28);
    panel.fillRoundedRect(panelX + 12, panelY + 12, panelW - 24, 13, 8);

    const pillW = Math.min(panelW - 36, 430);
    panel.fillStyle(tone.cssAccent === '#475569' ? 0x334155 : tone.accent, 0.94);
    panel.fillRoundedRect(panelX + 20, panelY - 22, pillW, 44, 22);
    panel.fillStyle(0xffffff, 0.16);
    panel.fillCircle(panelX + pillW - 28, panelY, 18);

    this.hudText
      .setText(`${presentation.chapterLabel} · ${scene.location}`)
      .setStyle(textStyle(compact ? 13 : 15, '#eff6ff', 800))
      .setPosition(panelX + 28, panelY - 14)
      .setWordWrapWidth(pillW - 56);

    const stateW = Math.min(width - margin * 2, 360);
    panel.fillStyle(0xffffff, 0.2);
    panel.fillRoundedRect(margin, margin + 18, stateW, compact ? 58 : 66, 22);
    panel.lineStyle(2, 0xffffff, 0.24);
    panel.strokeRoundedRect(margin, margin + 18, stateW, compact ? 58 : 66, 22);

    this.stateText
      .setText(presentation.stateLabel)
      .setStyle(textStyle(compact ? 13 : 14, '#eff6ff', 900))
      .setPosition(margin + 18, margin + 30)
      .setWordWrapWidth(stateW - 36);
    this.progressText
      .setText(`${Math.round(presentation.progressPercent * 100)}% practice path`)
      .setStyle(textStyle(12, '#dbeafe', 800))
      .setPosition(margin + 18, margin + (compact ? 56 : 60));

    this.focusText
      .setText(presentation.focusLabel)
      .setStyle(textStyle(compact ? 13 : 16, '#f8fafc', 700))
      .setPosition(width - margin - Math.min(width * 0.44, 420), margin + 26)
      .setWordWrapWidth(Math.min(width * 0.44, 420));
    this.focusText.setVisible(width >= 700);

    this.titleText
      .setText(scene.title)
      .setStyle(textStyle(compact ? 22 : 30, '#0f172a', 900))
      .setPosition(panelX + 24, panelY + 30)
      .setWordWrapWidth(panelW - 48);

    this.bodyText
      .setText(compact ? `${scene.body.split('. ')[0]}.` : scene.body)
      .setStyle({ ...textStyle(compact ? 14 : 16, '#24324a', 500), lineSpacing: compact ? 2 : 4 })
      .setPosition(panelX + 24, panelY + (compact ? 82 : 88))
      .setWordWrapWidth(panelW - 48);
  }

  private createFloatingAccents(): void {
    for (let index = 0; index < 14; index += 1) {
      const accent = this.add.circle(0, 0, 4, 0xffffff, 0.5).setDepth(1);
      this.floatingAccents.push(accent);
    }
  }

  private positionFloatingAccents(presentation: ScenePresentation): void {
    const { width, height } = this.scale;
    this.tweens.killTweensOf(this.floatingAccents);

    this.floatingAccents.forEach((accent, index) => {
      const column = index % 7;
      const row = Math.floor(index / 7);
      const x = width * (0.12 + column * 0.13) + (row === 0 ? 0 : width * 0.045);
      const y = height * (0.18 + row * 0.17) + ((index * 19) % 31);
      const radius = 2.4 + (index % 4);
      accent
        .setPosition(x, y)
        .setRadius(radius)
        .setFillStyle(index % 2 === 0 ? presentation.tone.glow : presentation.tone.accentAlt, 0.36)
        .setAlpha(this.currentSettings.reducedMotion ? 0.18 : 0.42)
        .setVisible(true);

      if (!this.currentSettings.reducedMotion) {
        this.tweens.add({
          targets: accent,
          y: y - 12 - (index % 3) * 6,
          alpha: 0.12,
          duration: 2200 + index * 95,
          yoyo: true,
          repeat: -1,
          ease: 'Sine.easeInOut',
        });
      }
    });
  }

  private drawSoftGlow(
    graphics: Phaser.GameObjects.Graphics,
    x: number,
    y: number,
    radius: number,
    color: number,
    alpha: number,
  ): void {
    for (let step = 4; step >= 1; step -= 1) {
      graphics.fillStyle(color, alpha / step);
      graphics.fillCircle(x, y, radius * (step / 4));
    }
  }

  private fillTrapezoid(
    graphics: Phaser.GameObjects.Graphics,
    x1: number,
    y1: number,
    x2: number,
    y2: number,
    x3: number,
    y3: number,
    x4: number,
    y4: number,
  ): void {
    graphics.beginPath();
    graphics.moveTo(x1, y1);
    graphics.lineTo(x2, y2);
    graphics.lineTo(x3, y3);
    graphics.lineTo(x4, y4);
    graphics.closePath();
    graphics.fillPath();
  }
}

function textStyle(fontSize: number, color: string, fontWeight: number): Phaser.Types.GameObjects.Text.TextStyle {
  return {
    color,
    fontFamily: FONT_STACK,
    fontSize: `${fontSize}px`,
    fontStyle: fontWeight >= 700 ? 'bold' : 'normal',
    lineSpacing: 2,
  };
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}
