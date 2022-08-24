# @esm2cjs/p-queue

This is a fork of https://github.com/sindresorhus/p-queue, but automatically patched to support ESM **and** CommonJS, unlike the original repository.

## Install

You can use an npm alias to install this package under the original name:

```
npm i p-queue@npm:@esm2cjs/p-queue
```

```jsonc
// package.json
"dependencies": {
    "p-queue": "npm:@esm2cjs/p-queue"
}
```

but `npm` might dedupe this incorrectly when other packages depend on the replaced package. If you can, prefer using the scoped package directly:

```
npm i @esm2cjs/p-queue
```

```jsonc
// package.json
"dependencies": {
    "@esm2cjs/p-queue": "^ver.si.on"
}
```

## Usage

```js
// Using ESM import syntax
import pQueue, { AbortError } from "@esm2cjs/p-queue";

// Using CommonJS require()
const pQueue = require("@esm2cjs/p-queue").default;
const { AbortError } = require("@esm2cjs/p-queue");
```

> **Note:**
> Because the original module uses `export default`, you need to append `.default` to the `require()` call to access `pQueue` itself.

For more details, please see the original [repository](https://github.com/sindresorhus/p-queue).

## Sponsoring

To support my efforts in maintaining the ESM/CommonJS hybrid, please sponsor [here](https://github.com/sponsors/AlCalzone).

To support the original author of the module, please sponsor [here](https://github.com/sindresorhus/p-queue).
