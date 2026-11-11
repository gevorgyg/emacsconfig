;;; init.el --- Single-File Emacs Bedrock (Core + GUI + Base UI + Dev) -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 1. Startup & GUI Settings (from Bedrock early-init.el & init.el)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq gc-cons-threshold 10000000)
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)

;; GUI & Frame Cleanup
(setq inhibit-startup-message t)
(setq frame-resize-pixelwise t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1) ; Set to 1 if you want the top menu bar

(modify-all-frames-parameters
 '((fullscreen . maximized)
   (vertical-scroll-bars . nil)
   (horizontal-scroll-bars . nil)))

;; Theme (Built-in high-contrast dark theme)
(load-theme 'modus-vivendi t)

;; Package Manager Setup
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 2. Bedrock Core Defaults (from Bedrock init.el)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setopt initial-major-mode 'fundamental-mode
        display-time-default-load-average nil
        auto-revert-avoid-polling t
        auto-revert-interval 5
        auto-revert-check-vc-info t
        sentence-end-double-space nil
        enable-recursive-minibuffers t
        completion-cycle-threshold 1
        completions-detailed t
        tab-always-indent 'complete
        completion-styles '(basic initials substring)
        completions-max-height 20
        completions-format 'one-column
        completions-group t
         completions-auto-select 'second-tab
        save-interprogram-paste-before-kill t
        help-window-select t
         visible-bell t
        x-underline-at-descent-line nil
        switch-to-buffer-obey-display-actions t
        show-trailing-whitespace nil
        indicate-buffer-boundaries 'left
        mouse-wheel-tilt-scroll t
        mouse-wheel-flip-direction t
        indent-tabs-mode nil
        tab-width 4)

(global-auto-revert-mode 1)
(savehist-mode 1)
(windmove-default-keybindings 'control) ; Ctrl + Arrow keys to switch windows
(line-number-mode 1)
(column-number-mode 1)
(pixel-scroll-precision-mode 1)
(which-key-mode 1) ; Built-in in Emacs 30/31

;; Keep auto-generated custom-set-variables out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 3. UI & Completion Enhancements (from Bedrock extras/base.el)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vertico: Vertical minibuffer completion UI
(use-package vertico
  :ensure t
  :init (vertico-mode 1))

;; Marginalia: Rich annotations in the minibuffer
(use-package marginalia
  :ensure t
  :init (marginalia-mode 1))

;; Orderless: Space-separated fuzzy matching
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Consult: Enhanced search and navigation commands
(use-package consult
  :ensure t
  :bind (("C-x b"   . consult-buffer)
         ("M-y"     . consult-yank-pop)
         ("M-s r"   . consult-ripgrep)
         ("M-s l"   . consult-line)
         ("M-g g"   . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g i"   . consult-imenu))
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

;; Corfu: In-buffer popup code completion
(use-package corfu
  :ensure t
  :init (global-corfu-mode 1)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  :bind (:map corfu-map
              ("SPC" . corfu-insert-separator)
              ("C-n" . corfu-next)
              ("C-p" . corfu-previous)))

(use-package corfu-popupinfo
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1)))

;; Avy: Jump to any visible text quickly
(use-package avy
  :ensure t
  :bind ("C-c j" . avy-goto-line))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 4. Developer Tools (from Bedrock extras/dev.el)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :config
  ;; Line numbers & current line highlight in code buffers
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'prog-mode-hook #'hl-line-mode)
  (add-hook 'prog-mode-hook #'electric-pair-mode)

  ;; Tree-sitter syntax highlighting & mode remapping
  (setopt treesit-font-lock-level 4)
  (setopt major-mode-remap-alist
          '((yaml-mode       . yaml-ts-mode)
            (bash-mode       . bash-ts-mode)
            (js2-mode        . js-ts-mode)
            (typescript-mode . typescript-ts-mode)
            (json-mode       . json-ts-mode)
            (css-mode        . css-ts-mode)
            (python-mode     . python-ts-mode)
            (c-mode          . c-ts-mode)
            (c++-mode        . c++-ts-mode))))

;; Built-in LSP Client (Eglot)
(use-package eglot
  :hook ((python-ts-mode
          c-ts-mode
          c++-ts-mode
          rust-ts-mode
          go-ts-mode
          js-ts-mode
          typescript-ts-mode) . eglot-ensure)
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)
  :config
  (fset #'jsonrpc--log-event #'ignore) ; Boost Eglot performance
  :bind (:map eglot-mode-map
              ("C-c l a" . eglot-code-actions)
              ("C-c l r" . eglot-rename)
              ("C-c l h" . eldoc)
              ("C-c l f" . eglot-format)
              ("C-c l F" . eglot-format-buffer)))

;; Magit: Git interface
(use-package magit
  :ensure t
  :bind ("C-c g" . magit-status))

;; Common File Format Modes
(use-package markdown-mode :ensure t)
(use-package yaml-mode :ensure t)
(use-package json-mode :ensure t)

;; Dumb Jump
(use-package dumb-jump
  :ensure t
  :init
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  :custom
  (dumb-jump-prefer-searcher 'rg))

;; Multiple Cursors
(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)        ; cursor on every line of the region
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)))
