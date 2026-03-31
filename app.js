const frame = document.querySelector(".frame");
const navLinks = [...document.querySelectorAll(".frame-nav a, .nav a")];
const sections = navLinks
  .map((link) => document.querySelector(link.getAttribute("href")))
  .filter(Boolean);
const metricValues = [...document.querySelectorAll(".metric-value[data-target]")];
let lastScrollTop = 0;

const formatMetric = (target, suffix = "") => {
  if (Number.isInteger(target)) {
    return `${target}${suffix}`;
  }

  return `${target.toFixed(2)}${suffix}`;
};

const animateMetric = (node) => {
  const target = Number(node.dataset.target);
  const suffix = node.dataset.suffix || "";

  if (Number.isNaN(target)) {
    return;
  }

  const duration = 1000;
  const start = performance.now();

  const tick = (now) => {
    const progress = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    const value = target * eased;
    node.textContent = formatMetric(value, suffix);

    if (progress < 1) {
      requestAnimationFrame(tick);
      return;
    }

    node.textContent = formatMetric(target, suffix);
  };

  requestAnimationFrame(tick);
};

if ("IntersectionObserver" in window) {
  const metricObserver = new IntersectionObserver(
    (entries, observer) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) {
          return;
        }

        animateMetric(entry.target);
        observer.unobserve(entry.target);
      });
    },
    { threshold: 0.45 }
  );

  metricValues.forEach((node) => metricObserver.observe(node));

  const sectionObserver = new IntersectionObserver(
    (entries) => {
      const visible = entries
        .filter((entry) => entry.isIntersecting)
        .sort((left, right) => right.intersectionRatio - left.intersectionRatio)[0];

      if (!visible) {
        return;
      }

      navLinks.forEach((link) => {
        const isActive = link.getAttribute("href") === `#${visible.target.id}`;
        link.classList.toggle("is-active", isActive);
      });
    },
    {
      rootMargin: "-20% 0px -55% 0px",
      threshold: [0.15, 0.3, 0.5],
    }
  );

  sections.forEach((section) => sectionObserver.observe(section));
} else {
  metricValues.forEach((node) => {
    node.textContent = formatMetric(Number(node.dataset.target), node.dataset.suffix || "");
  });
}

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
