(defconst cleverparens-lispy-packages
  '(lispyville
    lispy))

 (defun cleverparens-lispy/init-lispyville ()
  (use-package lispyville
    :defer t
    :init
    (add-hook 'lispy-mode-hook #'lispyville-mode)
    :config
    (lispyville-set-key-theme '(operators
                                additional-movement
                                escape
                                slurp/barf-lispy))))

(defun cleverparens-lispy/init-lispy ()
  (use-package lispy
    :defer t
    :init
    (add-hook 'emacs-lisp-mode-hook (lambda ()
                                      (lispy-mode 1)))))

(defun cleverparens-lispy/pre-init-smartparens ()
  (setq sp-highlight-pair-overlay nil)
  (setq sp-highlight-wrap-overlay nil)
  (setq sp-highlight-wrap-tag-overlay nil))

(defun cleverparens-lispy/post-init-smartparens ()
  (show-smartparens-global-mode -1))

(defun cleverparens-lispy/post-init-evil ()
  (setq evil-move-beyond-eol t))
