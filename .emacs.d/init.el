;;; init.el --- Emacs Configuration File  -*- lexical-binding: t; -*-
;;; Commentary:
;;; A comprehensive Emacs configuration with modern packages and settings

;;; Code:

;; Package management setup
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

;; Always ensure packages are installed
(setq use-package-always-ensure t)

;; Suppress byte-compile warnings for packages
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)

;; macOS key bindings - use Command (physical ALT) as Meta
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super)
  (setq mac-control-modifier 'control)
  (setq mac-function-modifier 'hyper))

;; UI Configuration
;; Hide menu bar, tool bar, and scroll bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Show line numbers globally
(global-display-line-numbers-mode 1)

;; Show column numbers in mode line
(column-number-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; Show matching parentheses
(show-paren-mode 1)

;; Basic editor settings
(setq-default
 indent-tabs-mode nil        ; Use spaces instead of tabs
 tab-width 4                 ; Set tab width to 4 spaces
 fill-column 80              ; Set line length to 80 characters
 truncate-lines t)           ; Don't wrap lines

;; Auto-backup and auto-save configuration
(setq make-backup-files t               ; Enable backup files
      backup-by-copying t               ; Don't clobber symlinks
      backup-directory-alist
      `((".*" . ,(expand-file-name "backups" user-emacs-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-saves/" user-emacs-directory) t))
      delete-old-versions t             ; Delete excess backup files silently
      kept-new-versions 6               ; Number of newest versions to keep
      kept-old-versions 2               ; Number of oldest versions to keep
      version-control t)                ; Use version numbers for backups

;; Enable auto-save
(setq auto-save-default t
      auto-save-timeout 20              ; Auto-save after 20 seconds of idle time
      auto-save-interval 200)           ; Auto-save after 200 keystrokes

;; Create backup and auto-save directories if they don't exist
(let ((backup-dir (expand-file-name "backups" user-emacs-directory))
      (auto-save-dir (expand-file-name "auto-saves" user-emacs-directory))
      (undo-tree-dir (expand-file-name "undo-tree-hist" user-emacs-directory)))
  (dolist (dir (list backup-dir auto-save-dir undo-tree-dir))
    (unless (file-exists-p dir)
      (make-directory dir t))))

;; Enable recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)

;; Better scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; Theme
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; Modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 25
        doom-modeline-bar-width 3
        doom-modeline-project-detection 'auto
        doom-modeline-buffer-file-name-style 'truncate-upto-project))

;; Icons (required for doom-modeline)
(use-package all-the-icons
  :if (display-graphic-p))

;; Org-mode configuration
(use-package org
  :config
  (setq org-startup-indented t
        org-pretty-entities t
        org-hide-emphasis-markers t
        org-startup-with-inline-images t
        org-image-actual-width '(300))
  
  ;; Org agenda files (customize as needed)
  (setq org-agenda-files '("~/org/"))
  
  ;; Org capture templates
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline "~/org/tasks.org" "Tasks")
           "* TODO %?\n  %i\n  %a")
          ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
           "* %?\nEntered on %U\n  %i\n  %a")))
  
  ;; Org babel languages
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t))))

;; Which-key for key binding help
(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.3))

;; Ivy/Counsel/Swiper for completion
(use-package ivy
  :init (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        enable-recursive-minibuffers t))

(use-package counsel
  :init (counsel-mode 1))

(use-package swiper
  :bind (("C-s" . swiper-isearch)))

;; Company for auto-completion
(use-package company
  :init (global-company-mode)
  :config
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 1
        company-selection-wrap-around t))

;; Flycheck for syntax checking
(use-package flycheck
  :init (global-flycheck-mode)
  :config
  ;; Reduce flycheck warnings
  (setq flycheck-emacs-lisp-load-path 'inherit)
  (setq flycheck-check-syntax-automatically '(save mode-enabled)))

;; Magit for Git integration
(use-package magit
  :bind (("C-x g" . magit-status))
  :config
  ;; Suppress magit auto-revert warnings
  (setq magit-auto-revert-mode nil))

;; Projectile for project management
(use-package projectile
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

;; Treemacs for file explorer
(use-package treemacs
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

;; Rainbow delimiters for better parentheses visibility
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Expand region for smart text selection
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; Multiple cursors
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

;; Avy for quick navigation
(use-package avy
  :bind (("C-:" . avy-goto-char)
         ("C-'" . avy-goto-char-2)
         ("M-g f" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)))

;; Ace-window for easy window switching
(use-package ace-window
  :bind (("M-o" . ace-window))
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (setq aw-scope 'frame)
  (setq aw-background t))

;; Undo tree for better undo/redo
(use-package undo-tree
  :init (global-undo-tree-mode)
  :config
  ;; Suppress undo-tree warnings
  (setq undo-tree-auto-save-history nil)
  (setq undo-tree-history-directory-alist 
        `((".*" . ,(expand-file-name "undo-tree-hist" user-emacs-directory)))))

;; Key bindings
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)

;; Custom functions
(defun my/reload-init-file ()
  "Reload init.el file."
  (interactive)
  (load-file user-init-file)
  (message "Reloaded init.el"))

(global-set-key (kbd "C-c r") 'my/reload-init-file)

;; Startup performance
(setq gc-cons-threshold (* 50 1000 1000))

;; Reduce warnings and improve performance
(setq load-prefer-newer t)
(setq ad-redefinition-action 'accept)
(setq warning-minimum-level :emergency)

;; Custom file for customizations
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here