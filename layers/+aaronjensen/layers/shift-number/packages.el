(defconst shift-number-packages '(shift-number))

(defun shift-number/init-shift-number ()
  (use-package shift-number
    :defer t
    :init
    (progn
      (define-key evil-normal-state-map (kbd "C-a") 'shift-number-up)
      (define-key evil-normal-state-map (kbd "C-S-a") 'shift-number-down))))
