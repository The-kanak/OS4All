/**
 * OS4All - Public Product Information Website
 * Vanilla JavaScript (No dependencies)
 */

document.addEventListener('DOMContentLoaded', () => {
  initMobileNavigation();
  initMockupTabs();
  initCodeTabs();
  initCopyButtons();
  initScrollSpy();
});

/* --------------------------------------------------------------------------
   Mobile Navigation Toggle
   -------------------------------------------------------------------------- */
function initMobileNavigation() {
  const toggleBtn = document.getElementById('navToggle');
  const navMenu = document.getElementById('navMenu');
  if (!toggleBtn || !navMenu) return;

  function toggleMenu() {
    const isExpanded = toggleBtn.getAttribute('aria-expanded') === 'true';
    toggleBtn.setAttribute('aria-expanded', String(!isExpanded));
    navMenu.classList.toggle('open');
  }

  function closeMenu() {
    toggleBtn.setAttribute('aria-expanded', 'false');
    navMenu.classList.remove('open');
  }

  toggleBtn.addEventListener('click', toggleMenu);

  // Close when clicking nav links
  const navLinks = navMenu.querySelectorAll('.nav-link');
  navLinks.forEach(link => {
    link.addEventListener('click', closeMenu);
  });

  // Close on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && navMenu.classList.contains('open')) {
      closeMenu();
    }
  });

  // Close on click outside
  document.addEventListener('click', (e) => {
    if (navMenu.classList.contains('open') && !navMenu.contains(e.target) && !toggleBtn.contains(e.target)) {
      closeMenu();
    }
  });
}

/* --------------------------------------------------------------------------
   Illustrative Mockup Interactive Switcher
   -------------------------------------------------------------------------- */
function initMockupTabs() {
  const tabBtns = document.querySelectorAll('.mockup-tab-btn');
  const contentPanels = document.querySelectorAll('.mockup-panel');

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const targetId = btn.getAttribute('data-target');

      tabBtns.forEach(b => b.classList.remove('active'));
      contentPanels.forEach(p => p.style.display = 'none');

      btn.classList.add('active');
      const targetPanel = document.getElementById(targetId);
      if (targetPanel) {
        targetPanel.style.display = 'flex';
      }
    });
  });
}

/* --------------------------------------------------------------------------
   Code Snippet Tabs in Explore / Setup Section
   -------------------------------------------------------------------------- */
function initCodeTabs() {
  const codeTabBtns = document.querySelectorAll('.code-tab-btn');
  const codeContents = document.querySelectorAll('.code-tab-content');

  codeTabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const targetId = btn.getAttribute('data-tab');

      codeTabBtns.forEach(b => b.classList.remove('active'));
      codeContents.forEach(c => c.classList.remove('active'));

      btn.classList.add('active');
      const activeContent = document.getElementById(targetId);
      if (activeContent) {
        activeContent.classList.add('active');
      }
    });
  });
}

/* --------------------------------------------------------------------------
   Copy to Clipboard Handler
   -------------------------------------------------------------------------- */
function initCopyButtons() {
  const copyBtns = document.querySelectorAll('.copy-btn');

  copyBtns.forEach(btn => {
    btn.addEventListener('click', async () => {
      const parentContainer = btn.closest('.code-tab-content') || btn.closest('.code-block-wrapper');
      if (!parentContainer) return;

      const codeElement = parentContainer.querySelector('pre code') || parentContainer.querySelector('pre');
      if (!codeElement) return;

      const rawText = codeElement.innerText;

      try {
        await navigator.clipboard.writeText(rawText);
        const originalHtml = btn.innerHTML;
        btn.innerHTML = `
          <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" stroke-width="2" fill="none">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
          Copied!
        `;
        btn.classList.add('copied');

        setTimeout(() => {
          btn.innerHTML = originalHtml;
          btn.classList.remove('copied');
        }, 2500);
      } catch (err) {
        console.warn('Clipboard write failed:', err);
      }
    });
  });
}

/* --------------------------------------------------------------------------
   ScrollSpy / Active Navigation Highlighting
   -------------------------------------------------------------------------- */
function initScrollSpy() {
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav-link');
  if (!sections.length || !navLinks.length) return;

  const observerOptions = {
    root: null,
    rootMargin: '-20% 0px -70% 0px',
    threshold: 0
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const id = entry.target.getAttribute('id');
        navLinks.forEach(link => {
          const href = link.getAttribute('href');
          if (href === `#${id}`) {
            link.classList.add('active');
          } else {
            link.classList.remove('active');
          }
        });
      }
    });
  }, observerOptions);

  sections.forEach(section => observer.observe(section));
}
