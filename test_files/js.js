/// Single-line comment
/* Block comment */
'use strict';

const PI = 3.14159;
let count = 0;

/**
 * Multi-line JSDoc comment
 * @param {number} r radius
 */
export function area(r = 1) {
  let localVar = r ** 2 * PI;
  console.log(`Area is ${localVar}`);
  return localVar;
}

class Shape {
  #privateField = 'hidden';
  constructor(name) {
    this.name = name ?? 'unknown';
  }
  static kind = '2D';
  get description() { return `${this.name} of kind ${Shape.kind}`; }
}

const arrow = (x) => x * 2;
await Promise.resolve().then(() => arrow(21));
// Single-line comment
/* Block comment */
'use strict';

const PI = 3.14159;
let count = 0;

/**
 * Multi-line JSDoc comment
 * @param {number} r radius
 */
export function area(r = 1) {
  let localVar = r ** 2 * PI;
  console.log(`Area is ${localVar}`);
  return localVar;
}

class Shape {
  #privateField = 'hidden';
  constructor(name) {
    this.name = name ?? 'unknown';
  }
  static kind = '2D';
  get description() { return `${this.name} of kind ${Shape.kind}`; }
}

const arrow = (x) => x * 2;
await Promise.resolve().then(() => arrow(21));
