(setq aj-deft-packages '(deft))

(defun aj-deft/post-init-deft ()
  (setq deft-extensions '("org" "txt"))
  (setq deft-org-mode-title-prefix t)
  (setq deft-use-filename-as-title nil)
  (setq deft-use-filter-string-for-filename t)
  (setq deft-auto-save-interval 2.0))
