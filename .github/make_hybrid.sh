#!/bin/bash

# un-ignore build folder
sed -i 's#/build##' .gitignore
sed -i 's#build/##' .gitignore

TSCONFIG=$(cat tsconfig.json | jq --tab '
	.compilerOptions.outDir = "build/esm"
	| .compilerOptions.module = "ESNext"
')
echo "$TSCONFIG" > tsconfig.json

# Replace module imports in all ts files
readarray -d '' files < <(find {source,test} \( -name "*.js" -o -name "*.ts" \) -print0)
function replace_imports () {
	from=$1
	to="${2:-@esm2cjs/$from}"
	for file in "${files[@]}" ; do
		sed -i "s#'$from'#'$to'#g" "$file"
	done
}
# replace_imports "FROM" "@esm2cjs/TO"
replace_imports "p-timeout" # to = "@esm2cjs/FROM"

# Fix tests
echo '{"type":"module"}' > test/package.json
sed -i 's#../source#../build/esm#' test/test.ts

PJSON=$(cat package.json | jq --tab '
	del(.type)
	| .description = .description + ". This is a fork of " + .repository + ", but with CommonJS support."
	| .repository = "esm2cjs/" + .name
	| .name |= "@esm2cjs/" + .
	| .author = { "name": "Dominic Griesel", "email": "d.griesel@gmx.net" }
	| .publishConfig = { "access": "public" }
	| .funding = "https://github.com/sponsors/AlCalzone"
	| .main = "build/cjs/index.js"
	| .module = "build/esm/index.js"
	| .files = ["build/"]
	| .exports = {}
	| .exports["."].import = "./build/esm/index.js"
	| .exports["."].require = "./build/cjs/index.js"
	| .exports["./package.json"] = "./package.json"
	| .types = "build/esm/index.d.ts"
	| .typesVersions = {}
	| .typesVersions["*"] = {}
	| .typesVersions["*"]["build/esm/index.d.ts"] = ["build/esm/index.d.ts"]
	| .typesVersions["*"]["build/cjs/index.d.ts"] = ["build/esm/index.d.ts"]
	| .typesVersions["*"]["*"] = ["build/esm/*"]
	| .scripts["to-cjs"] = "esm2cjs --in build/esm --out build/cjs -t node12"
	| .scripts.build = "del build/ && tsc"
	| .scripts.test = "xo && nyc ava"
	| del(.scripts.prepare)
	| .xo.ignores = ["build", "test", "**/*.test-d.ts", "**/*.d.ts"]

	| .dependencies["@esm2cjs/p-timeout"] = .dependencies["p-timeout"]
	| del(.dependencies["p-timeout"])
')
# Placeholder for custom deps:
	# | .dependencies["@esm2cjs/DEP"] = .dependencies["DEP"]
	# | del(.dependencies["DEP"])

echo "$PJSON" > package.json

# Update package.json -> version if upstream forgot to update it
if [[ ! -z "${TAG}" ]] ; then
	VERSION=$(echo "${TAG/v/}")
	PJSON=$(cat package.json | jq --tab --arg VERSION "$VERSION" '.version = $VERSION')
	echo "$PJSON" > package.json
fi

npm i
npm run build

npm i -D @alcalzone/esm2cjs
npm run to-cjs
npm uninstall -D @alcalzone/esm2cjs

PJSON=$(cat package.json | jq --tab 'del(.scripts["to-cjs"])')
echo "$PJSON" > package.json

npm test
