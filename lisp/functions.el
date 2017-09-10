;; (defun console-log-at-point()
;;   "console.log symbol at point on new line"
;;   (interactive)
;;   (er/mark-symbol)
;;   (message selection)
;;   (end-of-line)
;;   (newline-and-indent)
;;   (insert (concat "console.log(" selection ")" ))

;;   (setq selection (thing-at-point 'symbol))
;; (setq selection (buffer-substring (mark) (point)))

(defun console-log-at-point()
  "console.log word at point on new line"

  (interactive)
  (setq selection (thing-at-point 'word))
  (message selection)
  (end-of-line)
  (newline-and-indent)
  (insert (concat "console.log(" selection ")" ))
  )

(defun insert-filename()
  (interactive)
  (let (s)
    (setq s (file-name-sans-extension (buffer-name (current-buffer))))
    (insert s)
    ))
