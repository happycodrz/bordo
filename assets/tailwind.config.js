const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  purge: [
    '../**/*.html.eex',
    '../**/*.html.leex',
    '../**/views/**/*.ex',
    '../**/live/**/*.ex',
    './js/**/*.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
    spinner: (theme) => ({
      default: {
        color: '#7a8289', // color you want to make the spinner
        size: '1em', // size of the spinner (used for both width and height)
        border: '2px', // border-width of the spinner (shouldn't be bigger than half the spinner's size)
        speed: '500ms', // the speed at which the spinner should rotate
      },
    }),
  },
  variants: {
    // all the following default to ['responsive']
    spinner: ['responsive'],
  },
  plugins: [require('@tailwindcss/ui'), require('tailwindcss-spinner')()],
}
