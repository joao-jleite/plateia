// Uma linha de log por chamada, no formato do docs/ARQUITETURA.md §15:
// {fn, user, ms, upstream_calls}. `upstream_calls: 0` é a prova do cache.

export class Counter {
  n = 0;
  inc(): void {
    this.n++;
  }
}

export interface LogLine {
  fn: string;
  user: string;
  ms: number;
  upstream_calls: number;
  [extra: string]: unknown;
}

export function buildLogLine(
  fn: string,
  user: string,
  startedAt: number,
  upstreamCalls: number,
  extra: Record<string, unknown> = {},
  now: number = Date.now(),
): LogLine {
  return { fn, user, ms: now - startedAt, upstream_calls: upstreamCalls, ...extra };
}

export function logLine(line: LogLine): void {
  console.log(JSON.stringify(line));
}
