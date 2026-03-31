const frame = document.querySelector(".frame");
let lastScrollTop = 0;

if (frame) {
  window.addEventListener(
    "scroll",
    () => {
      const currentScrollTop = window.scrollY || document.documentElement.scrollTop;

      if (currentScrollTop <= 24) {
        frame.classList.remove("is-hidden");
        lastScrollTop = currentScrollTop;
        return;
      }

      const isScrollingDown = currentScrollTop > lastScrollTop;
      frame.classList.toggle("is-hidden", isScrollingDown && currentScrollTop > 140);
      lastScrollTop = currentScrollTop;
    },
    { passive: true }
  );
}
