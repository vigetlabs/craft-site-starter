/**
 * This runs within the DDEV container
 * We have access to the appropriate PHP & Composer versions
 */
export default {
  '**/*.php': [
    './vendor/bin/ecs check --ansi --fix',
    './vendor/bin/phpstan analyse --memory-limit=1G',
  ],
  '*.{js,jsx,ts,tsx}': ['eslint --fix', 'prettier --ignore-unknown --write'],
  // Negate the JS files above so there isn't a race condition
  // This runs prettier on every tyep of fiel but ths JS extensions listed below
  // https://github.com/lint-staged/lint-staged?tab=readme-ov-file#task-concurrency
  '!(*.js|*.jsx|*.ts|*.tsx)': 'prettier --ignore-unknown --write',
}
