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

;; (defun goto-interesting-symbol()
;;   (interactive)
;;   (search-forward "(")
;;   (search-forward "'")
;;   )



;; (defun jaga/narrow-to-line()
;;   (narrow-to-region (line-beginning-position) (line-end-position))
;;   )

;; (defun test()
;;   (interactive)
;;   (jaga/narrow-to-line)
;;   ;; (beginning-of-line)
;;   (if (search-forward ";")
;;       (message "trovato")
;;     (message "non trovato")
;;     )
;;   (widen)
;;   )

;; if selection active
;; (if (use-region-p)


;; (cond
;;  ((eq evil-state 'visual) (do-something))
;;  ((eq evil-state 'normal) (do-other-thing))
;;  ((eq evil-state 'insert) (do-another-thing)))

(defun backward-copy-word ()
  (interactive)
  (save-excursion
    (copy-region-as-kill (point) (progn (backward-word) (point)))))


(defun console-log-at-point()
  "console.log word at point on new line"

  (interactive)
  (setq jaga/selection (thing-at-point 'word))
  (message jaga/selection)
  (end-of-line)
  (newline-and-indent)
  (insert (concat "console.log(" jaga/selection ")" ))
  )

(defun insert-filename()
  (interactive)
  (let (s)
    (setq s (file-name-sans-extension (buffer-name (current-buffer))))
    (insert s)
    ))
(defun toggle-camelcase-underscores ()

  "Toggle between camelcase and underscore notation for the symbol at point."
  (interactive)
  (save-excursion
    (let* ((bounds (bounds-of-thing-at-point 'symbol))
           (start (car bounds))
           (end (cdr bounds))
           (currently-using-underscores-p (progn (goto-char start)
                                                 (re-search-forward "_" end t))))
      (if currently-using-underscores-p
          (progn
            (upcase-initials-region start end)
            (replace-string "_" "" nil start end)
            (downcase-region start (1+ start)))
        (replace-regexp "\\([A-Z]\\)" "_\\1" nil (1+ start) end)
        (downcase-region start (cdr (bounds-of-thing-at-point 'symbol)))))))

(defun nextjs-build-path(filename)
  filename
  (concat (projectile-project-root) "frontend/pages/" filename))


(defun nextjs-create-file(pagename)
  (let (
        (newbuf (generate-new-buffer-name pagename))
        (path (nextjs-build-path pagename))
        )
    (if (file-exists-p path)
        (message (concat "file exists: " path))
      (progn
        (write-region "" nil path) ; crate new file with no contenta at path
        (find-file path)))))

  (defun nextjs-new-page(pagename)
    "creates a new page in NextJS"
    (interactive (list (read-from-minibuffer "Page name: " `(,".js" . 1) nil nil nil)))
    (nextjs-create-file pagename))

  (defun  jsx-prop-every-selected-line(p1)
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
      (let ((p1))
        (save-excursion
          (setq p1 (region-beginning) )
          (jsx-prop-every-selected-line p1 ))))

     ((eq evil-state 'normal)
      (progn
        (setq jaga/selection (thing-at-point 'word))
        (when jaga/selection
          (progn
          (forward-word)
          (insert (concat "={" jaga/selection "}" ))))))

     ((eq evil-state 'insert)
      (progn
        (backward-copy-word)
        (insert "={")
        (yank)
        (insert "}")
        (evil-normal-state)))))
