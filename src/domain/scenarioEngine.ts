import type {
  DecisionRecord,
  ScenarioChoice,
  ScenarioContent,
  ScenarioResult,
  ScenarioScene,
  ScenarioSnapshot,
} from './types';

export class ScenarioValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ScenarioValidationError';
  }
}

export class ScenarioEngine {
  private readonly scenesById: Map<string, ScenarioScene>;
  private currentSceneId: string;
  private history: DecisionRecord[] = [];

  constructor(private readonly content: ScenarioContent) {
    this.scenesById = new Map(content.scenes.map((scene) => [scene.id, scene]));
    validateScenario(content, this.scenesById);
    this.currentSceneId = content.startSceneId;
  }

  get snapshot(): ScenarioSnapshot {
    const currentScene = this.requireScene(this.currentSceneId);
    return {
      scenarioId: this.content.id,
      currentScene,
      history: [...this.history],
      isComplete: currentScene.choices.length === 0,
      reflectionPrompts: this.history
        .map((record) => this.requireScene(record.sceneId).reflection)
        .filter((prompt): prompt is string => Boolean(prompt))
        .concat(currentScene.reflection ? [currentScene.reflection] : []),
    };
  }

  choose(choiceId: string): ScenarioResult {
    const scene = this.requireScene(this.currentSceneId);
    if (scene.choices.length === 0) {
      throw new ScenarioValidationError('This scenario path is already complete. Use reset to replay.');
    }

    const choice = scene.choices.find((candidate) => candidate.id === choiceId);
    if (!choice) {
      throw new ScenarioValidationError(`Choice "${choiceId}" is not available from scene "${scene.id}".`);
    }

    this.history.push({ sceneId: scene.id, choiceId: choice.id, safetyTag: choice.safetyTag });
    this.currentSceneId = choice.nextSceneId;

    return {
      snapshot: this.snapshot,
      consequence: consequenceFor(choice, this.snapshot.currentScene),
    };
  }

  reset(): ScenarioSnapshot {
    this.history = [];
    this.currentSceneId = this.content.startSceneId;
    return this.snapshot;
  }

  private requireScene(sceneId: string): ScenarioScene {
    const scene = this.scenesById.get(sceneId);
    if (!scene) {
      throw new ScenarioValidationError(`Missing scenario scene "${sceneId}".`);
    }
    return scene;
  }
}

export function validateScenario(content: ScenarioContent, scenesById = new Map(content.scenes.map((scene) => [scene.id, scene]))): void {
  if (content.ageRange !== '8-12') {
    throw new ScenarioValidationError('Scenario age range must be 8-12.');
  }
  if (!scenesById.has(content.startSceneId)) {
    throw new ScenarioValidationError(`Start scene "${content.startSceneId}" does not exist.`);
  }

  const decisionScenes = content.scenes.filter((scene) => scene.choices.length > 0);
  if (decisionScenes.length < 3 || decisionScenes.length > 5) {
    throw new ScenarioValidationError('Scenario must contain 3-5 decision-point scenes.');
  }

  const endingKinds = new Set(content.scenes.map((scene) => scene.ending).filter(Boolean));
  for (const required of ['supportive', 'trusted-adult', 'redirect', 'do-nothing']) {
    if (!endingKinds.has(required as never)) {
      throw new ScenarioValidationError(`Scenario is missing the ${required} ending path.`);
    }
  }

  for (const scene of content.scenes) {
    const choiceIds = new Set<string>();
    for (const choice of scene.choices) {
      if (choiceIds.has(choice.id)) {
        throw new ScenarioValidationError(`Duplicate choice "${choice.id}" in scene "${scene.id}".`);
      }
      choiceIds.add(choice.id);
      if (!scenesById.has(choice.nextSceneId)) {
        throw new ScenarioValidationError(`Choice "${choice.id}" points to missing scene "${choice.nextSceneId}".`);
      }
    }
  }
}

function consequenceFor(choice: ScenarioChoice, nextScene: ScenarioScene): string {
  if (nextScene.ending === 'do-nothing') {
    return 'You saw that doing nothing can leave someone alone, and the game offers a replay so you can practice another safe step.';
  }

  switch (choice.safetyTag) {
    case 'supportive':
      return 'Private support lowers attention and helps the classmate know they are not alone.';
    case 'trusted-adult':
      return 'Trusted-adult help shares the responsibility with someone whose job is to keep students safe.';
    case 'redirect':
      return 'A calm redirection can interrupt the moment without adding public pressure.';
    case 'mixed':
      return 'That choice came from wanting to help, but the story shows a safer repair step.';
    case 'observe':
      return 'Waiting can happen when a bystander feels unsure; you can still choose a safer next step.';
    case 'do-nothing':
      return 'Doing nothing is understandable when you freeze, but it usually gives the targeted person less support.';
  }
}
