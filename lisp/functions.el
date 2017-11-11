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

(defun get-current-selection ()
  (buffer-substring-no-properties (region-beginning) (region-end))
  )

(defun backward-copy-word ()
  (interactive)
  (save-excursion
    (copy-region-as-kill (point) (progn (backward-word) (point)))))

(defun debugger-next-line()
  "add debugger statement on next line"
  (interactive)
  (end-of-line) ; to prevent breaking a line a
  (newline-and-indent)
  (insert "debugger")
  )

(defun console-log-in-next-line(str)
  "console.log str on next line"
  (end-of-line) ; to prevent breaking a line a
  (newline-and-indent)
  (insert (concat "console.log(" str ")" ))
  )

(defun console-log-at-point()
  "console.log word at point on new line"
  (interactive)
  (if (use-region-p)
        (console-log-in-next-line (get-current-selection))
    (console-log-in-next-line (thing-at-point 'word))
    ))

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

(defun  jsx-prop-every-selected-line()
  (interactive "r")
  (let ((x (region-beginning)))
  (while (>= (point) x)
    (back-to-indentation)
    (deactivate-mark)
    (jsx-prop-at-point)
    (previous-line))))

(defun jsx-prop-at-point()
  (interactive)
  (cond
   ((use-region-p)
      (save-excursion
        (goto-char (region-end))
        (jsx-prop-every-selected-line)))

   ((eq evil-state 'normal)
    (let ((word (thing-at-point 'word)))
      (when word
        (forward-word)
        (insert (concat "={" word "}" )))))

   ((eq evil-state 'insert)
    (backward-copy-word)
    (insert "={")
    (yank)
    (insert "}")
    (evil-normal-state))))

(defun select-current-line ()
  "Select the current line"
  (interactive)
  (end-of-line) ; move to end of line
  (set-mark (line-beginning-position)))


(defun dwim-curly()
  (interactive)
  (cond

   ((eq evil-state 'normal)
    (let ((word (thing-at-point 'word)))
      (when word
        (backward-word)
        (insert "{")
         (forward-word)
        (insert "}")
        )
      ))

   ((eq evil-state 'insert)
      (backward-word)
      (insert "{")
      (forward-word)
      (insert "}")
    )))

(defun no-fix-js()
  (interactive)
  (prettier-js-mode 0)
  (eslintd-fix-mode 0)
  )

(defun linum-relative-evil-yank ()
  "Show relative numbering temporarily when yanking"
  (interactive)
  (linum-relative-on)
  (unwind-protect
      (progn
        (linum-mode 1)
        (call-interactively 'evil-yank))
    (linum-mode -1))
  )


(defun linum-relative-evil-delete ()
  "Show relative numbering temporarily when yanking"
  (interactive)
  (linum-relative-on)
  (unwind-protect
      (progn
        (linum-mode 1)
        (call-interactively 'evil-delete))
    (linum-mode -1))
  )
