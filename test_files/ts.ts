/* ts_syntax_stress.ts
 * A deliberately large, kitchen-sink TypeScript file to test syntax highlighting, parsing,
 * type-checking performance, and editor features. It favors breadth over practical design.
 */

/* ===========================================
 *  SECTION 0 — GLOBAL AMBIENTS & AUGMENTATION
 * =========================================== */

// Ambient declarations:
declare const __BUILD_ID__: string;
declare function fetch(
  input: RequestInfo,
  init?: RequestInit
): Promise<Response>;

// Global module augmentation example:
declare global {
  interface Array<T> {
    /** A silly extension to test declaration merging on built-ins. */
    firstOr<TDefault>(this: T[], d: TDefault): T | TDefault;
  }
  // Simulate Node-like require cache:
  var __cache__: Record<string, unknown> | undefined;
}

// Implementation of augmented method (allowed in global, but lives in this module runtime):
if (!Array.prototype.firstOr) {
  Array.prototype.firstOr = function <T, TDefault>(
    this: T[],
    d: TDefault
  ): T | TDefault {
    return this.length ? this[0]! : d;
  };
}

/* ============================
 *  SECTION 1 — UNIQUE SYMBOLS
 * ============================ */

export const BRAND: unique symbol = Symbol("BRAND");
type Branded<T, B extends string> = T & { readonly [BRAND]: B };

type UserId = Branded<string, "UserId">;
type OrderId = Branded<string, "OrderId">;

function asUserId(s: string): UserId {
  return s as UserId;
}
function asOrderId(s: string): OrderId {
  return s as OrderId;
}

/* ==================================
 *  SECTION 2 — ENUMS & CONST ENUMS
 * ================================== */

export enum LogLevel {
  DEBUG = 10,
  INFO = 20,
  WARN = 30,
  ERROR = 40,
}

export const enum ByteOrder {
  LE = 0,
  BE = 1,
}

/* ======================================
 *  SECTION 3 — INTERFACES & MERGING
 * ====================================== */

interface Point {
  readonly x: number;
  readonly y: number;
}

interface Point {
  label?: string; // declaration merging
}

interface JsonValue {
  // Recursive structural type:
  [k: string]:
    | string
    | number
    | boolean
    | null
    | JsonValue
    | JsonValue[]
    | { toJSON(): unknown };
}

// Index signatures + noUncheckedIndexedAccess-friendly access helpers:
type Dict<T> = { [k: string]: T | undefined };

/* =========================================
 *  SECTION 4 — TUPLES, VARIADIC TUPLES, R/O
 * ========================================= */

type RGB = readonly [r: number, g: number, b: number];
type Pair<T, U = T> = [T, U];

// Variadic tuple example:
type Prepend<T extends unknown[], H> = [H, ...T];
type Append<T extends unknown[], L> = [...T, L];

// Labeled tuple elements:
type HttpRange = [start: number, end: number];

/* ===========================================
 *  SECTION 5 — TEMPLATE LITERALS & CONDITIONALS
 * =========================================== */

type Join<K, P> = K extends string | number
  ? P extends string | number
    ? `${K}.${P}`
    : never
  : never;

type DotPaths<T, Prev extends string = ""> = {
  [K in keyof T & (string | number)]: T[K] extends object
    ? Join<Prev extends "" ? K : `${Prev}`, DotPaths<T[K], Join<Prev, K>>>
    : Join<Prev, K>;
}[keyof T & (string | number)];

type Primitive = string | number | boolean | null | undefined | symbol | bigint;

type DeepReadonly<T> = T extends Primitive
  ? T
  : T extends Function
  ? T
  : { readonly [K in keyof T]: DeepReadonly<T[K]> };

// Infer & distributive conditional type:
type ElementType<T> = T extends (infer U)[] ? U : T;
type AwaitedLike<T> = T extends Promise<infer U> ? U : T;

/* ============================================
 *  SECTION 6 — DECORATORS (Experimental)
 * ============================================ */

type Constructor<T = {}> = new (...args: any[]) => T;

function frozen<T extends Constructor>(Base: T): T {
  return class extends Base {
    constructor(...args: any[]) {
      super(...args);
      Object.freeze(this);
    }
  };
}

function logClass(prefix = "") {
  return function <T extends Constructor>(Base: T): T {
    return class extends Base {
      constructor(...args: any[]) {
        super(...args);
        console.log(`${prefix}${Base.name} constructed with`, args);
      }
    };
  };
}

function nonEnumerable(
  _: any,
  prop: string | symbol,
  desc: PropertyDescriptor
) {
  desc.enumerable = false;
  return desc;
}

/* ======================================
 *  SECTION 7 — NAMESPACES & MERGING
 * ====================================== */

export namespace MathEx {
  export const TAU = Math.PI * 2;

  export function clamp(n: number, min: number, max: number): number {
    return n < min ? min : n > max ? max : n;
  }

  export function* range(
    start: number,
    end: number,
    step = 1
  ): Generator<number, void> {
    for (let i = start; i < end; i += step) {
      yield i;
    }
  }

  export interface Random {
    seed(seed: number): void;
    next(): number; // [0,1)
  }
}

export namespace MathEx {
  // Declaration merging
  export class Mulberry32 implements Random {
    #a = 0;
    seed(seed: number) {
      this.#a = seed >>> 0;
    }
    next() {
      let t = (this.#a += 0x6d2b79f5);
      t = Math.imul(t ^ (t >>> 15), t | 1);
      t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    }
  }
}

/* ==================================
 *  SECTION 8 — MIXINS & CLASSES
 * ================================== */

interface Disposable {
  dispose(): void;
}

function Timestamped<TBase extends Constructor>(Base: TBase) {
  return class extends Base {
    readonly createdAt = new Date();
  };
}

abstract class Resource implements Disposable {
  #open = true;
  get isOpen() {
    return this.#open;
  }
  close() {
    this.#open = false;
  }
  dispose(): void {
    if (this.#open) this.close();
  }
  abstract describe(): string;
}

@logClass("[DBG] ")
@frozen
class FileResource extends Timestamped(Resource) {
  @nonEnumerable
  override describe() {
    return `FileResource(open=${
      this.isOpen
    }, created=${this.createdAt.toISOString()})`;
  }
}

/* ===========================================
 *  SECTION 9 — TYPE GUARDS & ASSERT FUNCTIONS
 * =========================================== */

function isNonNull<T>(v: T): v is NonNullable<T> {
  return v !== null && v !== undefined;
}

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === "object" && v !== null && !Array.isArray(v);
}

function assert(
  condition: unknown,
  msg = "Assertion failed"
): asserts condition {
  if (!condition) throw new Error(msg);
}

class FluentSafeBuilder<T extends object = {}> {
  private acc: Dict<unknown> = {};
  with<K extends string, V>(k: K, v: V) {
    this.acc[k] = v;
    return this as unknown as FluentSafeBuilder<T & Record<K, V>>;
  }
  build(this: FluentSafeBuilder<T>) {
    return this.acc as T;
  }
  assertsNonEmpty(
    this: FluentSafeBuilder<T>
  ): asserts this is FluentSafeBuilder<T> & { acc: Record<string, unknown> } {
    assert(Object.keys(this.acc).length > 0, "Empty");
  }
}

/* ======================================
 *  SECTION 10 — FUNCTION OVERLOADS
 * ====================================== */

function sum(a: number, b: number): number;
function sum(a: bigint, b: bigint): bigint;
function sum(a: number | bigint, b: number | bigint) {
  if (typeof a === "bigint" || typeof b === "bigint")
    return BigInt(a as any) + BigInt(b as any);
  return (a as number) + (b as number);
}

type Comparator<T> = (a: T, b: T) => number;

function sortBy<T>(arr: readonly T[], cmp?: Comparator<T>): T[];
function sortBy<T, K extends keyof T>(arr: readonly T[], key: K): T[];
function sortBy<T>(arr: readonly T[], keyOrCmp?: keyof T | Comparator<T>): T[] {
  const copy = arr.slice();
  const cmp: Comparator<T> =
    typeof keyOrCmp === "function"
      ? keyOrCmp
      : keyOrCmp
      ? (a, b) => ((a as any)[keyOrCmp] > (b as any)[keyOrCmp] ? 1 : -1)
      : (a, b) => (a > b ? 1 : -1);
  return copy.sort(cmp);
}
