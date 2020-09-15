import flatpickr from 'flatpickr'

export const DatePicker = {
  mounted() {
    flatpickr(this.el, {
      enableTime: true,
    })
  },
}
