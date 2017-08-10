(setq magit-push-always-verify nil)
(setq magit-popup-show-common-commands nil)
(setq magit-auto-revert-mode t)
(setq magit-revert-buffers 1)
(setq magit-commit-show-diff nil)
(setq magit-display-buffer-function 'magit-display-buffer-fullcolumn-most-v1)
(setq magit-diff-refine-hunk 'all)
(setq magit-delete-by-moving-to-trash nil)
(setq magit-revision-use-gravatar-kludge t)

;; https://github.com/vermiculus/magithub/issues/85#issuecomment-301669109
(with-eval-after-load 'ghub+
  (defun ghubp--remove-api-links (o &rest _) o))

;; Start commit in insert mode
(add-hook 'with-editor-mode-hook 'evil-insert-state)

;; Use C-n/C-p to navigate sections
(with-eval-after-load 'magit
  (evil-define-key 'normal magit-mode-map (kbd "C-n") 'magit-section-forward-sibling)
  (evil-define-key 'normal magit-mode-map (kbd "C-p") 'magit-section-backward-sibling))

;; Add SPC g c to stage all and commit while viewing the diff
(defun aj/magit-stage-all-and-commit ()
  (interactive)
  (magit-stage-modified t)
  (setq this-command 'magit-commit)
  (setq magit-commit-show-diff t)
  (magit-commit))
(advice-add 'magit-commit-diff :after (lambda ()
                                        "Disable magit-commit-show-diff."
                                        (setq magit-commit-show-diff nil)))
(spacemacs/set-leader-keys "gc" #'aj/magit-stage-all-and-commit)

(provide 'init-magit)
