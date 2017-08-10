(defconst aj-emacs-lisp-packages
  '(
    eros
    flycheck-package
    nameless))

(defun aj-emacs-lisp/init-eros ()
  (use-package eros
    :defer t
    :init
    (add-hook 'emacs-lisp-mode-hook #'eros-mode)))

(defun aj-emacs-lisp/init-flycheck-package ()
  (use-package flycheck-package
    :defer t
    :init
    (add-hook 'emacs-lisp-mode-hook #'flycheck-package-setup)))

(defun aj-emacs-lisp/init-nameless ()
  (use-package nameless
    :defer t
    :init
    (add-hook 'emacs-lisp-mode-hook #'nameless-mode)))

(defun aj-emacs-lisp/post-init-parinfer ()
  (with-eval-after-load 'parinfer-mode
    (parinfer-strategy-add 'instantly
      '(spacemacs/evil-mc-paste-after
        spacemacs/evil-mc-paste-before))))
