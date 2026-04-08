#!/bin/bash
set -euo pipefail

npm run changeset version
npm install --package-lock-only
npm install --prefix examples/browser --package-lock-only
npm install --prefix examples/expo --package-lock-only
npm install --prefix examples/node --package-lock-only