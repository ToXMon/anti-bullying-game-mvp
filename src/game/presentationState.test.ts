import { describe, expect, it } from 'vitest';
import { kindnessCrewScenario } from '../content/scenario';
import { ScenarioEngine } from '../domain/scenarioEngine';
import { buildPresentation } from './presentationState';

describe('buildPresentation', () => {
  it('starts with a chapter frame and an intentional first-step state', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);
    const presentation = buildPresentation(engine.snapshot, kindnessCrewScenario);

    expect(presentation).toMatchObject({
      chapterIndex: 1,
      totalChapters: 5,
      progressPercent: 0.12,
      mood: 'opening',
      isEnding: false,
      isReflection: false,
    });
    expect(presentation.focusLabel).toContain('no timer');
  });

  it('maps a private check-in to a calmer support atmosphere', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);
    const snapshot = engine.choose('private-support').snapshot;
    const presentation = buildPresentation(snapshot, kindnessCrewScenario);

    expect(presentation).toMatchObject({
      chapterIndex: 2,
      progressPercent: 0.2,
      mood: 'supportive',
      isTrustedAdult: false,
      isReflection: false,
    });
    expect(presentation.stateLabel).toContain('Private support');
  });

  it('keeps trusted-adult endings labeled as reflection states', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);
    engine.choose('trusted-adult');
    const snapshot = engine.choose('stay-nearby').snapshot;
    const presentation = buildPresentation(snapshot, kindnessCrewScenario);

    expect(presentation).toMatchObject({
      isEnding: true,
      isReflection: true,
      isTrustedAdult: true,
      mood: 'ending-positive',
      progressPercent: 1,
    });
    expect(presentation.chapterLabel).toContain('Reflection');
  });

  it('gives the do-nothing route a non-shaming replay state', () => {
    const engine = new ScenarioEngine(kindnessCrewScenario);
    engine.choose('wait-watch');
    const snapshot = engine.choose('keep-doing-nothing').snapshot;
    const presentation = buildPresentation(snapshot, kindnessCrewScenario);

    expect(presentation.mood).toBe('ending-do-nothing');
    expect(presentation.stateLabel).toContain('replay encouraged');
    expect(presentation.focusLabel).toContain('replay');
  });
});
