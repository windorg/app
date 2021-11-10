// Same as the official extension, just an older version because we can't grab it from Skypack anymore

import { Node, mergeAttributes } from 'https://cdn.skypack.dev/pin/@tiptap/core@v2.0.0-beta.103-1EijC0NTac4wtSFPah5m/mode=imports,min/optimized/@tiptap/core.js';
import { textblockTypeInputRule } from 'https://cdn.skypack.dev/pin/prosemirror-inputrules@v1.1.3-H1ealaYJwb2N1q4DVZgX/mode=imports,min/optimized/prosemirror-inputrules.js';

export const Heading = Node.create({
  name: 'heading',

  defaultOptions: {
    levels: [1, 2, 3, 4, 5, 6],
    HTMLAttributes: {},
  },

  content: 'inline*',

  group: 'block',

  defining: true,

  addAttributes() {
    return {
      level: {
        default: 1,
        rendered: false,
      },
    }
  },

  parseHTML() {
    return this.options.levels
      .map((level) => ({
        tag: `h${level}`,
        attrs: { level },
      }))
  },

  renderHTML({ node, HTMLAttributes }) {
    const hasLevel = this.options.levels.includes(node.attrs.level)
    const level = hasLevel
      ? node.attrs.level
      : this.options.levels[0]

    return [`h${level}`, mergeAttributes(this.options.HTMLAttributes, HTMLAttributes), 0]
  },

  addCommands() {
    return {
      setHeading: attributes => ({ commands }) => {
        if (!this.options.levels.includes(attributes.level)) {
          return false
        }

        return commands.setNode('heading', attributes)
      },
      toggleHeading: attributes => ({ commands }) => {
        if (!this.options.levels.includes(attributes.level)) {
          return false
        }

        return commands.toggleNode('heading', 'paragraph', attributes)
      },
    }
  },

  addKeyboardShortcuts() {
    return this.options.levels.reduce((items, level) => ({
      ...items,
      ...{
        [`Mod-Alt-${level}`]: () => this.editor.commands.toggleHeading({ level }),
      },
    }), {})
  },

  addInputRules() {
    return this.options.levels.map(level => {
      return textblockTypeInputRule(new RegExp(`^(#{1,${level}})\\s$`), this.type, { level })
    })
  },
})

export default Heading