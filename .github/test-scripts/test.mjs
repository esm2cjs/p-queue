import pQueue, { AbortError } from "@esm2cjs/p-queue";
import assert from "assert";

assert(typeof pQueue === "function");
assert(typeof AbortError === "function");
