# Architecture

## Goals

- As simple as possible
- Easy to contribute
  - Use PHP/Composer as much as possible for setup scripts
- Easy to test changes
  - Make it easy to `ddev start` this repo and test your plugin and build tool changes.
  - It should feel like you're working on a typical Craft project
- Cross-platform (Mac, Windows, Linux)
  - We can achieve this by using PHP/Composer and running scripts from within Docker containers.

## Overview

This starter is a Composer "project" that can be installed using `composer create-project`.

composer.json has a `post-create-project-cmd` [script](https://getcomposer.org/doc/articles/scripts.md) that will run after the project is created.

We use this hook to start the installation process (modify and delete files, edit config, etc).

Some aspects of the installation are single line bash scripts. However, more complex actions are handled by PHP files in the [install-scripts](/install-scripts) directory
