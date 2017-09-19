(defun  jsx-prop-every-selected-line(p1 p2)
  (interactive "r")
  (while (>= (point) p1)
    (back-to-indentation)
    (deactivate-mark)
    (jsx-prop-at-point)
    (previous-line)))

(defun jsx-prop-at-point()
  (interactive)
  (cond
   ((use-region-p)
    (let ((p1 p2))
      (save-excursion
        (setq p1 (region-beginning) p2 (region-end))
        (jsx-prop-every-selected-line p1 p2))))

   ((eq evil-state 'normal)
    (progn
      (setq jaga/selection (thing-at-point 'word))
      (when jaga/selection
        (forward-word)
        (insert (concat "={" jaga/selection "}" )))))

   ((eq evil-state 'insert)
    (progn
      (utils/backward-copy-word)
      (insert "={")
      (yank)
      (insert "}")
      (evil-normal-state)))))
