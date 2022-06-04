#!/bin/bash

parse_env() {
  if [ ! -f "${script_dir}/.env" ]; then
    echo -e "\n\nFile ${script_dir}/.env not found, the file: ${script_dir}/.env.local will be copied for you\n\n"
    cp ${script_dir}/.env.local ${script_dir}/.env
  fi
  set -a
  . "${script_dir}/.env"
  set +a
  if [ -z "$UID" ]; then
    echo >&2
    echo "IMPORTANT: the env var UID is not set, it is important to set it inside ${script_dir}/.env" >&2
    echo >&2
  fi
}

parse_env

echo "Creating a new typescript package" &&
mkdir my-new-typescript-package && cd my-new-typescript-package && \

#echo "Initializing git repository" && \
#git init && \
#echo "# My New typescript package" >> README.md && \
#git remote add origin git@github.com:farsabbutt/my-new-typescript-package.git && \
#git push -u origin master && \

echo "Initializing NPM package" && \
npm init -y && \
echo "node_modules" >> .gitignore && \

echo "Installing Typescript" && \
npm install --save-dev typescript

echo "Creating Typescript configuration file" && \
cat <<EOT >> tsconfig.json
{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "declaration": true,
    "outDir": "./lib",
    "strict": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "**/__tests__/*"]
}
EOT

echo "Creating source folder and main package file"
mkdir src && echo "export const Greeter = (name: string) => 'Hello there'; " >> src/index.ts

echo "Configuring build script in package.json" && \
#npm install -g npm-add-script && \
npx npm-add-script -k "build" -v "tsc" && \

echo "Building the package" && \
npm run build
echo "lib" >> .gitignore

echo "Installing TsLint and Prettier" && \
npm install --save-dev prettier tslint tslint-config-prettier && \

echo "Configuring Tslint" && \
cat <<EOT >> tslint.json
{
   "extends": ["tslint:recommended", "tslint-config-prettier"]
}
EOT

echo "Configuring Prettier" && \
cat <<EOT >> .prettierrc
{
  "printWidth": 120,
  "trailingComma": "all",
  "singleQuote": true
}
EOT

echo "Configuring format and lint scripts in package.json" && \
#npm install -g npm-add-script && \
npx npm-add-script -k "format" -v "prettier --write \"src/**/*.ts\"" && \
npx npm-add-script -k "lint" -v "tslint -p tsconfig.json" && \

echo "Linting" && \
npm run lint && \

echo "Formatting" && \
npm run format && \

echo "Adding configuration to whitelist build files that need to be pushed to npm registry" && \
node -e "let pkg=require('./package.json'); pkg.files=[\"lib/**/*\"]; require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));" && \

echo "Setup jest for testing" && \
npm install --save-dev jest ts-jest @types/jest &&

echo "Add jest configuration" && \
cat <<EOT >> jestconfig.json
{
  "transform": {
    "^.+\\\\.(t|j)sx?$": "ts-jest"
  },
  "testRegex": "(/__tests__/.*|(\\\\.|/)(test|spec))\\\\.(jsx?|tsx?)$",
  "moduleFileExtensions": ["ts", "tsx", "js", "jsx", "json", "node"]
}
EOT
node -e "let pkg=require('./package.json'); pkg.scripts.test='jest --config jestconfig.json'; require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));" && \
mkdir src/__tests__ && \
cat <<EOT >> src/__tests__/index.test.ts
import { Greeter } from '../index';
test('Main Test', () => {
  expect(Greeter('')).toBe('Hello there');
});
EOT

echo "Running tests" && \
npm test && \

echo "Configuring npm scripts: 'prepare', 'prepublishOnly', 'preversion', 'version', 'postversion'" && \
node -e "let pkg=require('./package.json'); pkg.scripts.prepare='npm run build'; pkg.scripts.prepublishOnly='npm test && npm run lint'; pkg.scripts.preversion='npm run lint'; pkg.scripts.version='npm run format && git add -A src'; pkg.scripts.postversion='git push && git push --tags'; require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2));"
