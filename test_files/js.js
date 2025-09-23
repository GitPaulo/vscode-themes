/// Single-line comment
/* Block comment */
'use strict';

export const VERSION = '1.0.0';
export const PI = 3.14159;
let count = 0n; // BigInt example

/**
 * Multi-line JSDoc comment
 * @param {number} r radius
 * @returns {number}
 */
export function area(r = 1) {
  let localVar = r ** 2 * PI;
  console.log(`Area is ${localVar}`);
  return localVar;
}

// Tagged template literal
function raw(strings, ...values) {
  return strings.raw[0] + values.join(',');
}
console.log(raw`Tagged\nTemplate ${42}`);

// Class with private field, static block, getter/setter
export class Shape {
  #privateField = 'hidden';
  static kind = '2D';

  constructor(name) {
    this.name = name ?? 'unknown';
  }

  get description() { return `${this.name} of kind ${Shape.kind}`; }
  set rename(n) { this.name = n; }

  reveal() { return this.#privateField; }

  static {
    // static initialization block
    console.log('Shape class loaded');
  }
}

// Async function with destructuring, optional chaining
export async function fetchData(url) {
  try {
    const res = await fetch(url);
    const { status, headers } = res;
    console.log(`Status: ${status}, Content-Type: ${headers.get('content-type')}`);
    return res?.ok ? await res.text() : null;
  } catch (err) {
    console.error('Fetch failed', err);
    return null;
  }
}

// Generator and async generator
export function* idGenerator(start = 0) {
  let i = start;
  while (true) yield i++;
}

export async function* asyncCounter(limit = 3) {
  for (let i = 0; i < limit; i++) {
    await new Promise(r => setTimeout(r, 10));
    yield i;
  }
}

// Proxy & Reflect
const handler = {
  get(target, prop, receiver) {
    console.log(`Accessing ${String(prop)}`);
    return Reflect.get(target, prop, receiver);
  }
};
export const proxied = new Proxy({ a: 1, b: 2 }, handler);

// Map/Set/WeakMap
const s = new Set([1, 2, 3]);
const m = new Map([[Symbol('k'), 'v']]);
const wm = new WeakMap();
const keyObj = {};
wm.set(keyObj, 'secret');

// Arrow function & spread/rest
export const arrow = (x, ...rest) => ({ doubled: x * 2, rest });

// Top-level await demo
await (async () => {
  console.log('Starting async section');
  for await (const v of asyncCounter(2)) {
    console.log('async count:', v);
  }
  console.log('Done async section');
})();

// Error handling example
try {
  if (Math.random() > 0.5) throw new Error('Random failure');
} catch (e) {
  console.error('Caught:', e.message);
} finally {
  console.log('Cleanup complete');
}

// Default export (optional)
export default {
  area,
  Shape,
  arrow,
  idGenerator
};
