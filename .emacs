;; Window customization
(defun efs/default-startup()
  (toggle-scroll-bar -1)      ;; Disable the scrollbar
  (load-theme 'nord t)
)

(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(alpha-background . 95))

;; Font configuration
(setq efs/default-font-size 116)
(setq efs/default-variable-font-size 13)

(defun efs/set-font-faces()
  (set-face-attribute 'default nil :font "Victor Mono" :height efs/default-font-size :weight 'semi-bold)

  ;; Set the fixed pitch face
  (set-face-attribute 'fixed-pitch nil :font "Victor Mono" :height efs/default-font-size :weight 'semi-bold)

  ;; Other atrributes for style
  (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
  (set-face-attribute 'font-lock-constant-face nil :slant 'italic)
  (set-face-attribute 'font-lock-keyword-face nil :slant 'italic)

  ;; Set the variable pitch face
  (set-face-attribute 'variable-pitch nil :font "Cantarell" :height efs/default-variable-font-size :weight 'regular)
)

(if (daemonp)
     (add-hook 'after-make-frame-functions
     	      (lambda (frame)
     		(with-selected-frame frame
     		  (efs/set-font-faces)
     		  (efs/default-startup))))
  (efs/set-font-faces)
  (efs/default-startup)
)

(setq inhibit-startup-message t)

(tool-bar-mode -1)            ;; Disable the toolbar
(toggle-scroll-bar -1)        ;; Disable the scrollbar
(tooltip-mode -1)             ;; Disable the tooltips
(set-fringe-mode 10)          ;; Give some breathing room

(menu-bar-mode -1)            ;; Disable the menu bar

(desktop-save-mode 1)

;; Reverse colors for the border to have nicer line  
(set-face-inverse-video-p 'vertical-border nil)
(set-face-background 'vertical-border (face-background 'default))

;; Set symbol for the border
(set-display-table-slot standard-display-table
                        'vertical-border 
                        (make-glyph-code ?┃))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Initialize package sources
(require 'package)

(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
 
(setq package-enable-at-startup nil)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  package-install 'use-package)

(require 'use-package)
(setq use-package-always-ensure t)

;; Themes
(use-package doom-themes)
(use-package nord-theme)

(column-number-mode)
(global-display-line-numbers-mode)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
		treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Use ivy and council 
(use-package ivy
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 :map ivy-switch-buffer-map
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; NOTE: The first time you load your configuration on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly:
;;
;; M-x nerd-icons-install-fonts

(use-package nerd-icons)

(use-package nyan-mode)

;; Customize modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 19)
  (nyan-mode 1)
  (nyan-animate-nyancat 1)
  (nyan-bar-length 70))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; Setup counsel
(use-package counsel
  :bind (("M-x". counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))

;; Helpful package
(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package fzf)

;; Key bindings
(use-package general
  :config
  (general-create-definer rune/leader-keys
  :keymaps '(normal insert visual emacs)
  :prefix "SPC"
  :global-prefix "C-r")

  (rune/leader-keys
   "t" '(:ignore t :which-key "treemacs")))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(rune/leader-keys
  "ts" '(hydra-text-scale/body :whcih-key "scale text"))

;; Projectile
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom (projectile-completion-system 'ivy)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~Projectile/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

;; Magit
(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Org setup
(defun os/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(defun os/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  
 ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(use-package org
  :hook (org-mode . os/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files
	'("~/Projects/Code/emacs-from-scratch/OrgFiles/Tasks.org"
	  "~/Projects/Code/emacs-from-scratch/OrgFiles/Habits.org"
	  "~/Projects/Code/emacs-from-scratch/OrgFiles/Birthdays.org"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  (setq org-refile-targets
    '(("Archive.org" :maxlevel . 1)
      ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Projects/Code/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Projects/Code/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Projects/Code/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Projects/Code/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ("m" "Metrics Capture")
      ("mw" "Weight" table-line (file+headline "~/Projects/Code/OrgFiles/Metrics.org" "Weight")
       "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))
  (os/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun os/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . os/org-mode-visual-fill))

;; Org Babel
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

;; Language server protocol
(defun os/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deffered)
  :init (setq lsp-keymap-prefix "C-c l")
  :hook (
         (c++-mode . lsp)
	 (c-mode . lsp)
	 (lsp-mode . os/lsp-mode-setup))
  :config
  (lsp-enable-which-key-integration t)
  :commands lsp
  :bind
  ("M-RET" . lsp-goto-type-definition))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-ivy
  :after lsp
  :commands lsp-ivy-workspace-symbol)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package flycheck)

;; DAP
(use-package dap-mode
  :defer
  :config  
  (setq dap-lldb-debug-program '("/usr/bin/lldb-vscode"))
  ;; Ask user for executable to debug if not specified explicitly (c++)
  (setq dap-lldb-debugged-program-function (lambda () (read-file-name "Select file to debug.")))

  ;; Default debug template for (c++)
  (dap-register-debug-template
   "C++ LLDB dap"
   (list :type "lldb-vscode"
         :cwd nil
         :args nil
         :request "launch"
         :program nil))
  (defun dap-debug-create-or-edit-json-template ()
    (interactive)
    (let ((filename (concat (lsp-workspace-root) "/launch.json"))
	  (default "~/.emacs.d/default-launch.json"))
      (unless (file-exists-p filename)
	(copy-file default filename))
      (find-file-existing filename)))
  :custom
  (dap-ui-mode t)
  (dap-tooltip-mode t)
  (tooltip-mode t)
  (dap-ui-controls-mode t)
  (dap-auto-configure-mode t)
  (dap-auto-configure-features
   '(sessions locals breakpoints expressions tooltip)))

;; C++
(require 'dap-lldb)

;; ;; Python
;; (use-package python-mode
;;   :ensure nil
;;   :hook (python-mode . lsp-deferred)
;;   :custom
;;   (python-shell-interpreter "python3"))

;; (use-package lsp-python-ms
;;   :ensure t
;;   :init (setq lsp-python-ms-auto-install-server t)
;;   :hook (python-mode . (lambda ()
;;                           (require 'lsp-python-ms))))


;; CMake
;;(setq load-path (cons (expand-file-name "~/.emacs.d/elpa/cmake-mode") load-path))
;;(require 'cmake-mode)

;; Dired
(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :hook (dired-mode . dired-hide-details-mode)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first")))

(use-package dired-single)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (define-key dired-mode-map
   "H" 'dired-hide-dotfiles-mode)
  )

;; Smart tabs
;;(use-package smart-tabs-mode)

;(smart-tabs-insinuate 'c 'c++)

;; straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
      (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
        "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
        'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(use-package app-launcher
  :straight '(app-launcher :host github :repo "SebastienWae/app-launcher"))

(use-package ligature
    :straight '(ligature :host github :repo "mickeynp/ligature.el")
    :config
  ;; Enable the "www" ligature in every possible major mode
  ;;(ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  ;;(ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Victor Mono ligatures in programming modes
    (ligature-set-ligatures 'prog-mode
        '("</" "</>" "/>" "~-" "-~" "~@" "<~" "<~>" "<~~" "~>" "~~" "~~>" ">=" "<="
          "<!--" "|-" "##" "###" "####" "-|" "|->" "<-|" ">-|" "|-<" "|=" "|=>" ">-"
          "<-" "<--" "-->" "->" "-<" ">->" ">>-" "<<-" "<->" "->>" "-<<" "<-<" "==>" "=>"
          "=/=" "!==" "!=" "<==" ">>=" "=>>" ">=>" "<=>" "<=<" "=<=" "=>=" "<<=" "=<<"
          ".-" ".=" "=:=" "=!=" "==" "===" "::" ":=" ":>" ":<" ">:" "<:" "\;\;" "=~" "!~" "::<"
          "<|" "<|>" "|>" "<>" "<$" "<$>" "$>" "<+" "<+>" "+>" "?=" "/=" "/==" "/\\" "\\/" "__" "&&"
          "++" "+++"))
  
    ;; Enables ligature checks globally in all buffers. You can also do it
    ;; per mode with `ligature-mode'.
    (global-ligature-mode t))

(defun emacs-run-launcher ()
  "Create and select a frame called emacs-run-launcher which consists only of
    a minibuffer and has specific dimensions. Run counsel-linux-app on that frame,
    which is an emacs command that prompts you to select an app and open it in a dmenu like behaviour.
    Delete the frame after that command has exited"
  (interactive)
  (with-selected-frame
      (make-frame '((name . "emacs-run-launcher")
		    (minibuffer . only)
		    (fullscreen . 0)      ;; disable fullscreen
		    (undecoreted . t)     ;; disable title bar
		    (width . 120)
		    (height . 11)))
    (unwind-protect
	(app-launcher-run-app)
      (delete-frame))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(button ((t ("#2E3440" nil "#88C0D0" :background :box nil))))
 '(font-lock-comment-face ((t (:foreground "#616e88" :slant italic))))
 '(font-lock-keyword-face ((t (:foreground "#81A1C1" :slant italic)))))
