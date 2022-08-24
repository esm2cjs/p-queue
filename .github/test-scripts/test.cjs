const pQueue = require("@esm2cjs/p-queue").default;
const { AbortError } = require("@esm2cjs/p-queue");
const assert = require("assert");

assert(typeof pQueue === "function");
assert(typeof AbortError === "function");
