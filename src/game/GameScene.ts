import Phaser from 'phaser';
import type { GameSettings } from '../persistence/settingsStore';
import type { ScenarioContent, ScenarioSnapshot } from '../domain/types';

export const GAME_READY_EVENT = 'game:ready';
export const SCENE_UPDATED_EVENT = 'scenario:snapshot';
export const SETTINGS_UPDATED_EVENT = 'settings:changed';

const BACKGROUND_KEY = 'courtyard-background';
const FALLBACK_KEY = 'fallback-background';

export class GameScene extends Phaser.Scene {
  private currentSnapshot?: ScenarioSnapshot;
  private currentSettings: GameSettings = { reducedMotion: false };
  private titleText?: Phaser.GameObjects.Text;
  private bodyText?: Phaser.GameObjects.Text;
  private statusText?: Phaser.GameObjects.Text;
  private helperSprites: Phaser.GameObjects.Arc[] = [];
  private background?: Phaser.GameObjects.Image | Phaser.GameObjects.Rectangle;
  private missingAsset = false;

  constructor(private readonly scenario: ScenarioContent) {
    super('game');
  }

  preload(): void {
    this.load.on('loaderror', (file: { key?: string }) => {
      if (file.key === BACKGROUND_KEY) {
        this.missingAsset = true;
      }
    });
    this.load.image(BACKGROUND_KEY, this.scenario.optionalBackgroundAsset);
  }

  create(): void {
    this.createFallbackTexture();
    this.drawBaseScene();

    this.game.events.on(SCENE_UPDATED_EVENT, (snapshot: ScenarioSnapshot) => {
      this.currentSnapshot = snapshot;
      this.redrawSnapshot();
    });

    this.game.events.on(SETTINGS_UPDATED_EVENT, (settings: GameSettings) => {
      this.currentSettings = settings;
      this.redrawSnapshot();
    });

    this.game.events.emit(GAME_READY_EVENT);

    if (this.currentSnapshot) {
      this.redrawSnapshot();
    }
  }

  private drawBaseScene(): void {
    const { width, height } = this.scale;
    const hasBackground = !this.missingAsset && this.textures.exists(BACKGROUND_KEY);
    this.background = hasBackground
      ? this.add.image(width / 2, height / 2, BACKGROUND_KEY).setDisplaySize(width, height)
      : this.add.rectangle(width / 2, height / 2, width, height, 0xdbeafe);

    if (!hasBackground) {
      this.add.image(width / 2, height / 2, FALLBACK_KEY).setDisplaySize(width, height).setAlpha(0.9);
    }

    this.add.rectangle(width / 2, height - 86, width - 56, 132, 0xffffff, 0.88).setStrokeStyle(4, 0x93c5fd);
    this.titleText = this.add.text(36, height - 142, '', {
      color: '#172033',
      fontFamily: 'Arial, sans-serif',
      fontSize: '28px',
      fontStyle: 'bold',
      wordWrap: { width: width - 72 },
    });
    this.bodyText = this.add.text(36, height - 100, '', {
      color: '#24324a',
      fontFamily: 'Arial, sans-serif',
      fontSize: '18px',
      lineSpacing: 4,
      wordWrap: { width: width - 72 },
    });
    this.statusText = this.add.text(36, 28, '', {
      color: '#14398f',
      fontFamily: 'Arial, sans-serif',
      fontSize: '18px',
      fontStyle: 'bold',
      backgroundColor: '#ffffffcc',
      padding: { x: 12, y: 8 },
    });

    this.helperSprites = [
      this.add.circle(width * 0.35, height * 0.48, 26, 0x2258d6),
      this.add.circle(width * 0.5, height * 0.45, 28, 0x1f8a5b),
      this.add.circle(width * 0.65, height * 0.5, 24, 0xf59e0b),
    ];
  }

  private redrawSnapshot(): void {
    if (!this.currentSnapshot || !this.titleText || !this.bodyText || !this.statusText) return;
    const scene = this.currentSnapshot.currentScene;
    this.titleText.setText(scene.title);
    this.bodyText.setText(scene.body);
    this.statusText.setText(
      this.missingAsset
        ? 'Fallback art active · use the accessible choices on the right'
        : 'Use the accessible choices on the right',
    );

    const targetScale = scene.choices.length === 0 ? 1.15 : 1;
    this.helperSprites.forEach((sprite, index) => {
      sprite.setFillStyle(scene.ending === 'do-nothing' ? 0x64748b : [0x2258d6, 0x1f8a5b, 0xf59e0b][index]);
      if (!this.currentSettings.reducedMotion) {
        this.tweens.add({
          targets: sprite,
          scale: targetScale,
          duration: 450,
          yoyo: true,
          ease: 'Sine.easeInOut',
        });
      } else {
        sprite.setScale(targetScale);
      }
    });
  }

  private createFallbackTexture(): void {
    if (this.textures.exists(FALLBACK_KEY)) return;
    const graphics = this.make.graphics({ x: 0, y: 0 }, false);
    graphics.fillGradientStyle(0xeef4ff, 0xeef4ff, 0xfff7ed, 0xfff7ed, 1);
    graphics.fillRect(0, 0, 960, 640);
    graphics.fillStyle(0x93c5fd, 1);
    graphics.fillRoundedRect(80, 370, 800, 96, 26);
    graphics.fillStyle(0xbfdbfe, 1);
    graphics.fillCircle(150, 170, 70);
    graphics.fillCircle(820, 150, 95);
    graphics.fillStyle(0x86efac, 1);
    graphics.fillRoundedRect(0, 455, 960, 185, 24);
    graphics.generateTexture(FALLBACK_KEY, 960, 640);
    graphics.destroy();
  }
}
