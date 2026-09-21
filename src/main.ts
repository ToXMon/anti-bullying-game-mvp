import Phaser from 'phaser';
import './styles.css';
import { kindnessCrewScenario } from './content/scenario';
import { ScenarioEngine } from './domain/scenarioEngine';
import { AccessibilityOverlay } from './ui/accessibilityOverlay';
import { GAME_READY_EVENT, GameScene, SCENE_UPDATED_EVENT, SETTINGS_UPDATED_EVENT } from './game/GameScene';
import { LocalSettingsStore } from './persistence/settingsStore';

const overlayRoot = document.querySelector<HTMLElement>('#accessibility-overlay');
const gameContainer = document.querySelector<HTMLElement>('#game-container');

if (!overlayRoot || !gameContainer) {
  throw new Error('Game containers were not found in the page.');
}

const engine = new ScenarioEngine(kindnessCrewScenario);
const settingsStore = new LocalSettingsStore();
let settings = settingsStore.load();

const game = new Phaser.Game({
  type: Phaser.AUTO,
  parent: gameContainer,
  backgroundColor: '#dbeafe',
  scale: {
    mode: Phaser.Scale.RESIZE,
    parent: gameContainer,
    width: gameContainer.clientWidth,
    height: gameContainer.clientHeight,
  },
  render: {
    antialias: true,
    pixelArt: false,
  },
  audio: {
    disableWebAudio: true,
    noAudio: true,
  },
  scene: [new GameScene(kindnessCrewScenario)],
});

const overlay = new AccessibilityOverlay(overlayRoot, {
  onChoice(choiceId) {
    const result = engine.choose(choiceId);
    game.events.emit(SCENE_UPDATED_EVENT, result.snapshot);
    return result;
  },
  onReset() {
    const snapshot = engine.reset();
    game.events.emit(SCENE_UPDATED_EVENT, snapshot);
    return snapshot;
  },
  onSettingsChange(nextSettings) {
    settings = nextSettings;
    settingsStore.save(settings);
    game.events.emit(SETTINGS_UPDATED_EVENT, settings);
  },
}, settings);

overlay.render(engine.snapshot);

game.events.once(GAME_READY_EVENT, () => {
  game.events.emit(SETTINGS_UPDATED_EVENT, settings);
  game.events.emit(SCENE_UPDATED_EVENT, engine.snapshot);
});
