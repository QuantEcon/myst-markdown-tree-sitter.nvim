/* ============================================
   myst-markdown-tree-sitter.nvim — Website JS
   Minimal interactions: nav toggle, tabs,
   smooth scroll, scroll reveal
   ============================================ */

(function () {
  'use strict';

  // --- Mobile nav toggle ---
  const navToggle = document.getElementById('nav-toggle');
  const navLinks = document.getElementById('nav-links');

  if (navToggle && navLinks) {
    navToggle.addEventListener('click', () => {
      navLinks.classList.toggle('open');
      navToggle.classList.toggle('active');
    });

    // Close mobile nav when clicking a link
    navLinks.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        navLinks.classList.remove('open');
        navToggle.classList.remove('active');
      });
    });
  }

  // --- Installation tabs ---
  const tabBtns = document.querySelectorAll('.tab-btn');
  const tabContents = document.querySelectorAll('.tab-content');

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-tab');

      tabBtns.forEach(b => b.classList.remove('active'));
      tabContents.forEach(c => c.classList.remove('active'));

      btn.classList.add('active');
      const targetEl = document.getElementById('tab-' + target);
      if (targetEl) targetEl.classList.add('active');
    });
  });

  // --- Hero theme switcher ---
  const themeTabs = document.querySelectorAll('.theme-tab');
  const heroCodeWindow = document.querySelector('.hero-code .code-window');

  themeTabs.forEach(tab => {
    tab.addEventListener('click', () => {
      const themeId = tab.getAttribute('data-theme-id');

      themeTabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      if (heroCodeWindow) {
        heroCodeWindow.setAttribute('data-theme', themeId);
      }
    });
  });

  // --- Scroll reveal ---
  const revealElements = () => {
    // Apply reveal class to section elements
    const sections = document.querySelectorAll(
      '.feature-card, .command-card, .lang-card, .config-block, .install-requirements, .faq-item'
    );
    sections.forEach(el => {
      if (!el.classList.contains('reveal')) {
        el.classList.add('reveal');
      }
    });
  };

  const handleScroll = () => {
    const reveals = document.querySelectorAll('.reveal');
    const windowHeight = window.innerHeight;

    reveals.forEach(el => {
      const top = el.getBoundingClientRect().top;
      if (top < windowHeight - 60) {
        el.classList.add('visible');
      }
    });
  };

  // --- Active nav link highlighting ---
  const updateActiveNav = () => {
    const sections = document.querySelectorAll('section[id]');
    const navAnchors = document.querySelectorAll('.nav-links a[href^="#"]');
    let current = '';

    sections.forEach(section => {
      const top = section.getBoundingClientRect().top;
      if (top <= 120) {
        current = section.getAttribute('id');
      }
    });

    navAnchors.forEach(a => {
      a.classList.remove('active');
      if (a.getAttribute('href') === '#' + current) {
        a.classList.add('active');
      }
    });
  };

  // --- Nav background on scroll ---
  const nav = document.getElementById('nav');
  const updateNavBg = () => {
    if (!nav) return;
    if (window.scrollY > 20) {
      nav.style.borderBottomColor = 'var(--border-default)';
    } else {
      nav.style.borderBottomColor = 'transparent';
    }
  };

  // --- Initialize ---
  revealElements();
  handleScroll();
  updateNavBg();

  window.addEventListener('scroll', () => {
    handleScroll();
    updateActiveNav();
    updateNavBg();
  }, { passive: true });

  // --- Smooth scroll for anchor links (fallback for older browsers) ---
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', (e) => {
      const href = anchor.getAttribute('href');
      if (href === '#') return;

      const target = document.querySelector(href);
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth' });
        // Update URL without jumping
        history.pushState(null, null, href);
      }
    });
  });
})();
