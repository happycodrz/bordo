export const AutoGrow = {
  mount() {
    this.el.style.height = "10px";
  },
  updated() {
    this.el.style.height = (this.el.scrollHeight + 10)+"px";
  }
}
