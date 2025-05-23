#!/usr/bin/env bash

## Description: Analyze and visualize the Vite bundle with the current project
## OSTypes: darwin
## Usage: vite-visualizer
## Example: "ddev vite-visualizer"
## See: https://www.npmjs.com/package/vite-bundle-visualizer

ddev exec npx vite-bundle-visualizer -o vite-bundle-visualizer.html

open "${DDEV_APPROOT}/vite-bundle-visualizer.html"