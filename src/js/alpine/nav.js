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
  /**
   * @param {KeyboardEvent} event
   */
  handleEscape(event) {
    if (this.stack.length === 0) {
      return
    }
    // Prevent the event from bubbling up if we have nav to pop
    event.stopPropagation()

    this.popStack(1)
  },
  handleTab() {
    const activeSubnavId = this.stack.at(-1)

    if (!activeSubnavId) {
      return
    }

    const activeSubnav = document.getElementById(activeSubnavId)

    if (!activeSubnav) {
      return
    }

    this.$nextTick(() => {
      const activeElement = document.activeElement

      // If document.activeElement is within activeSubnav, do nothing
      if (!activeElement || activeSubnav.contains(activeElement)) {
        return
      }

      // If document.activeElement is not within $root, reset the stack
      if (!this.$root.contains(activeElement)) {
        this.resetStack()
        return
      }

      // Focused toggle
      const idOfFocusedSubnav = activeElement.getAttribute('aria-controls')
      const focusedSubnavLevel = idOfFocusedSubnav
        ? document.getElementById(idOfFocusedSubnav)?.dataset.level
        : null

      // Edge case, we're still in the nav component, but somehow what we're focused on doesn't have subnav or level
      if (!focusedSubnavLevel) {
        this.popStack(1, false)
        return
      }

      // Pop everything down to the level of the focused subnav
      const currentLevel = this.stack.length
      this.popStack(currentLevel - parseInt(focusedSubnavLevel, 10) + 1, false)
    })
  },
})
