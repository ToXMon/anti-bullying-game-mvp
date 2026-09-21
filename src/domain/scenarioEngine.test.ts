import { describe, expect, it } from 'vitest';
import { kindnessCrewScenario } from '../content/scenario';
import { ScenarioEngine, validateScenario } from './scenarioEngine';

describe('Kindness Crew scenario', () => {
  it('meets the scenario structure contract', () => {
    expect(() => validateScenario(kindnessCrewScenario)).not.toThrow();

    const decisionScenes = kindnessCrewScenario.scenes.filter((scene) => scene.choices.length > 0);
    expect(decisionScenes).toHaveLength(5);
    expect(kindnessCrewScenario.ageRange).toBe('8-12');
    expect(kindnessCrewScenario.estimatedMinutes).toBe('8-12 minutes');
  });

  it('lets a player practice private support and then replay safely', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);

    let result = engine.choose('private-support');
    expect(result.snapshot.currentScene.id).toBe('private-check-in');
    expect(result.consequence).toContain('Private support');

    result = engine.choose('invite-friend');
    expect(result.snapshot.isComplete).toBe(true);
    expect(result.snapshot.currentScene.ending).toBe('supportive');
    expect(result.snapshot.currentScene.reflection).toBeTruthy();

    const replay = engine.reset();
    expect(replay.isComplete).toBe(false);
    expect(replay.currentScene.id).toBe(kindnessCrewScenario.startSceneId);
    expect(replay.history).toEqual([]);
  });

  it('supports a clear trusted-adult escalation path', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);

    const first = engine.choose('trusted-adult');
    expect(first.snapshot.currentScene.adultHelp).toContain('Trusted adults');

    const ending = engine.choose('stay-nearby');
    expect(ending.snapshot.isComplete).toBe(true);
    expect(ending.snapshot.currentScene.ending).toBe('trusted-adult');
    expect(ending.snapshot.currentScene.adultHelp).toContain('danger');
  });

  it('supports safe redirection without requiring confrontation', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);

    expect(engine.choose('safe-redirection').snapshot.currentScene.id).toBe('redirect-supplies');
    const ending = engine.choose('pair-with-sam');

    expect(ending.snapshot.isComplete).toBe(true);
    expect(ending.snapshot.currentScene.ending).toBe('redirect');
    expect(ending.consequence).toContain('redirection');
  });

  it('keeps the do-nothing path understandable and non-terminal for learning through replay', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);

    expect(engine.choose('wait-watch').snapshot.currentScene.id).toBe('watching');
    const ending = engine.choose('keep-doing-nothing');

    expect(ending.snapshot.isComplete).toBe(true);
    expect(ending.snapshot.currentScene.ending).toBe('do-nothing');
    expect(ending.consequence).toContain('replay');
    expect(engine.reset().currentScene.id).toBe('courtyard-start');
  });

  it('rejects unavailable choices instead of moving state silently', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);

    expect(() => engine.choose('not-a-choice')).toThrow(/not available/);
    expect(engine.snapshot.currentScene.id).toBe('courtyard-start');
  });
});
