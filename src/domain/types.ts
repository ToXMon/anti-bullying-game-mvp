export type EndingKind = 'supportive' | 'trusted-adult' | 'redirect' | 'do-nothing';

export interface ScenarioChoice {
  id: string;
  label: string;
  description: string;
  nextSceneId: string;
  safetyTag: EndingKind | 'observe' | 'mixed';
}

export interface ScenarioScene {
  id: string;
  title: string;
  location: string;
  body: string;
  prompt: string;
  reflection?: string;
  adultHelp?: string;
  choices: ScenarioChoice[];
  ending?: EndingKind;
}

export interface ScenarioContent {
  id: string;
  title: string;
  ageRange: string;
  estimatedMinutes: string;
  safetyNote: string;
  optionalBackgroundAsset: string;
  startSceneId: string;
  scenes: ScenarioScene[];
}

export interface DecisionRecord {
  sceneId: string;
  choiceId: string;
  safetyTag: ScenarioChoice['safetyTag'];
}

export interface ScenarioSnapshot {
  scenarioId: string;
  currentScene: ScenarioScene;
  history: DecisionRecord[];
  isComplete: boolean;
  reflectionPrompts: string[];
}

export interface ScenarioResult {
  snapshot: ScenarioSnapshot;
  consequence: string;
}
