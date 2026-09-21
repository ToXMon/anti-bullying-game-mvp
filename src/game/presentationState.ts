import type { ScenarioContent, ScenarioScene, ScenarioSnapshot } from '../domain/types';

export type PresentationMood =
  | 'opening'
  | 'supportive'
  | 'trusted-adult'
  | 'redirect'
  | 'observe'
  | 'repair'
  | 'ending-positive'
  | 'ending-do-nothing';

export interface SceneTone {
  skyTop: number;
  skyBottom: number;
  horizon: number;
  ground: number;
  accent: number;
  accentAlt: number;
  glow: number;
  shadow: number;
  cssAccent: string;
  cssSoft: string;
  label: string;
}

export interface ScenePresentation {
  sceneIndex: number;
  chapterIndex: number;
  totalChapters: number;
  progressPercent: number;
  chapterLabel: string;
  stateLabel: string;
  focusLabel: string;
  mood: PresentationMood;
  tone: SceneTone;
  isEnding: boolean;
  isTrustedAdult: boolean;
  isReflection: boolean;
}

const TONES: Record<PresentationMood, SceneTone> = {
  opening: {
    skyTop: 0x2f6bd9,
    skyBottom: 0xffd7a8,
    horizon: 0xc7ddff,
    ground: 0x7cc7a8,
    accent: 0x2563eb,
    accentAlt: 0xf59e0b,
    glow: 0xfff3b0,
    shadow: 0x172033,
    cssAccent: '#2563eb',
    cssSoft: '#eff6ff',
    label: 'sunlit courtyard',
  },
  supportive: {
    skyTop: 0x227fb5,
    skyBottom: 0xbaf7d3,
    horizon: 0xd6f7ff,
    ground: 0x65c18f,
    accent: 0x0f9f75,
    accentAlt: 0x60a5fa,
    glow: 0xcffafe,
    shadow: 0x153642,
    cssAccent: '#0f9f75',
    cssSoft: '#ecfdf5',
    label: 'quiet support',
  },
  'trusted-adult': {
    skyTop: 0x293e8f,
    skyBottom: 0xf8c773,
    horizon: 0xdbeafe,
    ground: 0x7eb38f,
    accent: 0x4f46e5,
    accentAlt: 0xf59e0b,
    glow: 0xfff0b8,
    shadow: 0x121a3a,
    cssAccent: '#4f46e5',
    cssSoft: '#eef2ff',
    label: 'trusted-adult help',
  },
  redirect: {
    skyTop: 0x0f76a8,
    skyBottom: 0xffdda7,
    horizon: 0xcdf5ff,
    ground: 0x86d1a5,
    accent: 0xea8a1a,
    accentAlt: 0x14b8a6,
    glow: 0xfff7c2,
    shadow: 0x223047,
    cssAccent: '#d97706',
    cssSoft: '#fff7ed',
    label: 'gentle redirection',
  },
  observe: {
    skyTop: 0x536e98,
    skyBottom: 0xd4def2,
    horizon: 0xe2e8f0,
    ground: 0x94a3b8,
    accent: 0x64748b,
    accentAlt: 0x93c5fd,
    glow: 0xe0f2fe,
    shadow: 0x1f2937,
    cssAccent: '#475569',
    cssSoft: '#f1f5f9',
    label: 'pause and notice',
  },
  repair: {
    skyTop: 0x6d4aa2,
    skyBottom: 0xfbcfe8,
    horizon: 0xf5d0fe,
    ground: 0xa7d5b1,
    accent: 0xa855f7,
    accentAlt: 0xf97316,
    glow: 0xfde68a,
    shadow: 0x31264f,
    cssAccent: '#9333ea',
    cssSoft: '#faf5ff',
    label: 'repair moment',
  },
  'ending-positive': {
    skyTop: 0x1d7dc2,
    skyBottom: 0xfed7aa,
    horizon: 0xd9f99d,
    ground: 0x54b98b,
    accent: 0x16a34a,
    accentAlt: 0xfbbf24,
    glow: 0xfef3c7,
    shadow: 0x123229,
    cssAccent: '#15803d',
    cssSoft: '#f0fdf4',
    label: 'reflection ending',
  },
  'ending-do-nothing': {
    skyTop: 0x475569,
    skyBottom: 0xcbd5e1,
    horizon: 0xe2e8f0,
    ground: 0x9ca3af,
    accent: 0x64748b,
    accentAlt: 0xf59e0b,
    glow: 0xffedd5,
    shadow: 0x1e293b,
    cssAccent: '#475569',
    cssSoft: '#f8fafc',
    label: 'try another safe step',
  },
};

export function buildPresentation(snapshot: ScenarioSnapshot, scenario: ScenarioContent): ScenePresentation {
  const scene = snapshot.currentScene;
  const sceneIndex = scenario.scenes.findIndex((candidate) => candidate.id === scene.id);
  const totalChapters = scenario.scenes.filter((candidate) => candidate.choices.length > 0).length;
  const chapterIndex = chapterFor(snapshot, totalChapters);
  const mood = moodFor(scene, snapshot.isComplete);
  const tone = TONES[mood];
  const isTrustedAdult = Boolean(scene.adultHelp) || mood === 'trusted-adult';
  const stateLabel = stateFor(scene, snapshot.isComplete, mood);

  return {
    sceneIndex,
    chapterIndex,
    totalChapters,
    progressPercent: progressFor(snapshot, totalChapters),
    chapterLabel: snapshot.isComplete
      ? `Reflection · path ${Math.max(1, snapshot.history.length)} of ${totalChapters}`
      : `Chapter ${chapterIndex} of ${totalChapters}`,
    stateLabel,
    focusLabel: focusFor(scene, snapshot.isComplete, mood),
    mood,
    tone,
    isEnding: snapshot.isComplete,
    isTrustedAdult,
    isReflection: snapshot.isComplete || Boolean(scene.reflection),
  };
}

function chapterFor(snapshot: ScenarioSnapshot, totalChapters: number): number {
  if (totalChapters <= 0) return 1;
  if (snapshot.isComplete) return Math.min(totalChapters, Math.max(1, snapshot.history.length));
  return Math.min(totalChapters, Math.max(1, snapshot.history.length + 1));
}

function progressFor(snapshot: ScenarioSnapshot, totalChapters: number): number {
  if (totalChapters <= 0) return 1;
  if (snapshot.isComplete) return 1;
  return Math.min(0.92, Math.max(0.12, snapshot.history.length / totalChapters));
}

function moodFor(scene: ScenarioScene, isComplete: boolean): PresentationMood {
  if (isComplete) {
    return scene.ending === 'do-nothing' ? 'ending-do-nothing' : 'ending-positive';
  }
  if (scene.id.includes('public') || scene.id.includes('secrecy')) return 'repair';
  if (scene.adultHelp || scene.id.includes('adult')) return 'trusted-adult';
  if (scene.id.includes('redirect')) return 'redirect';
  if (scene.id.includes('watch')) return 'observe';
  if (scene.id.includes('private')) return 'supportive';
  return 'opening';
}

function stateFor(scene: ScenarioScene, isComplete: boolean, mood: PresentationMood): string {
  if (isComplete) {
    return scene.ending === 'do-nothing' ? 'Reflection · replay encouraged' : 'Reflection ending · replay ready';
  }
  switch (mood) {
    case 'trusted-adult':
      return 'Trusted-adult pathway';
    case 'supportive':
      return 'Private support pathway';
    case 'redirect':
      return 'Gentle redirection pathway';
    case 'observe':
      return 'Pause-and-notice moment';
    case 'repair':
      return 'Repair and lower attention';
    default:
      return 'Title scene · choose a safe first step';
  }
}

function focusFor(scene: ScenarioScene, isComplete: boolean, mood: PresentationMood): string {
  if (isComplete) return 'Read the reflection, then replay to practice another safe choice.';
  if (scene.adultHelp) return 'A trusted adult can help keep responsibility with a grown-up.';
  switch (mood) {
    case 'supportive':
      return 'Keep support private, calm, and led by what Sam needs.';
    case 'redirect':
      return 'Lower the spotlight with a neutral activity and leave room for adult help.';
    case 'observe':
      return 'Freezing can happen; a small next step can still help.';
    case 'repair':
      return 'Helping works best when it lowers attention instead of raising it.';
    default:
      return 'There is no timer: choose a safe bystander step when ready.';
  }
}
