export interface GameSettings {
  reducedMotion: boolean;
}

const STORAGE_KEY = 'kindness-crew-settings-v1';

export interface SettingsStore {
  load(): GameSettings;
  save(settings: GameSettings): void;
  reset(): void;
}

export class LocalSettingsStore implements SettingsStore {
  load(): GameSettings {
    const fallback = defaultSettings();
    if (!storageAvailable()) {
      return fallback;
    }

    try {
      const raw = window.localStorage.getItem(STORAGE_KEY);
      if (!raw) return fallback;
      const parsed = JSON.parse(raw) as Partial<GameSettings>;
      return {
        reducedMotion: typeof parsed.reducedMotion === 'boolean' ? parsed.reducedMotion : fallback.reducedMotion,
      };
    } catch {
      return fallback;
    }
  }

  save(settings: GameSettings): void {
    if (!storageAvailable()) return;
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify({ reducedMotion: settings.reducedMotion }));
  }

  reset(): void {
    if (!storageAvailable()) return;
    window.localStorage.removeItem(STORAGE_KEY);
  }
}

export function defaultSettings(): GameSettings {
  const reducedMotion =
    typeof window !== 'undefined' &&
    typeof window.matchMedia === 'function' &&
    window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  return { reducedMotion };
}

function storageAvailable(): boolean {
  try {
    return typeof window !== 'undefined' && Boolean(window.localStorage);
  } catch {
    return false;
  }
}
