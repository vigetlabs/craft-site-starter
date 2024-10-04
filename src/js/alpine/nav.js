export default () => ({
  /** @type {string[]} */
  stack: [],
  popStack(popTimes = 1, focus = true) {
    const idToFocus = this.stack.at(-1 * popTimes)

    if (idToFocus && focus) {
      const elementToFocus = document.querySelector(
        `[aria-controls="${idToFocus}"]`,
      )
      this.$focus.focus(elementToFocus)
    }

    this.stack = this.stack.slice(0, popTimes * -1)
  },
  pushStack(id) {
    this.stack.push(id)

    const elementToFocus = document.getElementById(id)
    this.$focus.within(elementToFocus).first()
  },
  resetStack() {
    this.stack = []
  },
  toggle(subnav) {
    if (!subnav) {
      this.resetStack()
      return
    }

    const level = parseInt(subnav.dataset.level, 10)
    const currentLevel = this.stack.length
    const shouldPush = !this.isInStack(subnav)
    if (level <= currentLevel) {
      // Remove everything down to the level you clicked.
      this.popStack(currentLevel - level + 1)
    }
    // If you clicked a toggle outside of the current stack, push it to the stack
    if (shouldPush) {
      this.pushStack(subnav.id)
    }
  },
  shouldTrap(el) {
    // You could modify this to only trap at a mobile sized match media
    return this.isInStack(el)
  },
  isInStack(el) {
    return this.stack.includes(el.id)
  },
  handleTab() {
    const el = document.getElementById(this.stack.at(-1))

    if (!el) {
      return
    }

    this.$nextTick(() => {
      if (!el.contains(document.activeElement)) {
        this.popStack(1, false)
      }
    })
  },
})
