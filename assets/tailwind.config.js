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
        sans: ['Muli', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        red: {
          '100': '#FFF0F0',
          '200': '#FFCFD0',
          '300': '#FFABAE',
          '400': '#FF8589',
          '500': '#FF595F',
          '600': '#E83339',
          '700': '#CF1D23',
          '800': '#A81116',
          '900': '#800F13',
        },
        blue: {
          '100': '#CAE8FA',
          '200': '#A7DAFA',
          '300': '#7FC8F5',
          '400': '#53B2ED',
          '500': '#2F96D6',
          '600': '#1A7EBD',
          '700': '#0F6396',
          '800': '#0D496E',
          '900': '#132836',
        },
        gray: {
          '50': '#f9fafb',
          '100': '#DEDEDE',
          '200': '#C7C7C7',
          '300': '#ADADAD',
          '400': '#8F8F8F',
          '500': '#737373',
          '600': '#5C5C5C',
          '700': '#454647',
          '800': '#323436',
          '900': '#222426',
        },
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
