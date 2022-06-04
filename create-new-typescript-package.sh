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

echo "Configuring build script in package.json"
npm install -g npm-add-script && \
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
npm install -g npm-add-script && \
npx npm-add-script -k "format" -v "prettier --write \"src/**/*.ts\"" && \
npx npm-add-script -k "lint" -v "tslint -p tsconfig.json" && \

echo "Linting" && \
npm run lint && \

echo "Formatting" && \
npm run format
