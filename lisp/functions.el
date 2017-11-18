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


(defun set-mellow-theme()
  (interactive)
  (deftheme mellow "Mellow.")

(custom-theme-set-faces
  'mellow
   '(default ((t (
                  :family "Source Code Pro"
                  :foundry "unknown"
                  :width normal
                  ;; :height 113
                  :weight normal
                  :slant normal
                  :underline nil
                  :overline nil
                  :strike-through nil
                  :box nil
                  :inverse-video nil
                  :foreground "#F8F8F2"
                  :background "#36312C"
                  :stipple nil
                  :inherit nil
                  ))))
'(cursor ((t (:background "#f8f8f0"))))
'(fixed-pitch ((t (:family "Monospace"))))
'(variable-pitch ((t (:family "Sans Serif"))))
'(escape-glyph ((t (:foreground "brown"))))
'(minibuffer-prompt ((t (:foreground "#F2BC79"))))
'(highlight ((t (:background "#ffe792" :foreground "#000000"))))
'(region ((t (:background "#F55D79"
              :foreground "#ffffff"))))
'(shadow ((t (:foreground "#3b3a32"))))
'(secondary-selection ((t (:background "#F55D79"))))
'(font-lock-builtin-face ((t (:foreground "#F2BC79"))))
'(font-lock-comment-delimiter-face ((default (:inherit (font-lock-comment-face)))))
'(font-lock-comment-face ((t (:foreground "#7A7267"))))
'(font-lock-constant-face ((t (:foreground "#1F8181"))))
'(font-lock-doc-face ((t (:foreground "#a09688"))))
'(font-lock-function-name-face ((t (:foreground "#F28972"))))
'(font-lock-keyword-face ((t (:foreground "#F55D79"))))
'(font-lock-negation-char-face ((t nil)))
'(font-lock-preprocessor-face ((t (:foreground "#F55D79"))))
'(font-lock-regexp-grouping-backslash ((t (:inherit (bold)))))
'(font-lock-regexp-grouping-construct ((t (:inherit (bold)))))
'(font-lock-string-face ((t (:foreground "#F8BB39"))))
'(font-lock-type-face ((t (:inherit 'default))))
'(font-lock-variable-name-face ((t (:foreground "#F2BC79"))))
'(font-lock-warning-face ((t (:background "#00a8c6" :foreground "#f8f8f0"))))
'(button ((t (:inherit (link)))))
'(link ((((class color) (min-colors 88) (background light)) (:underline (:color foreground-color :style line) :foreground "RoyalBlue3")) (((class color) (background light)) (:underline (:color foreground-color :style line) :foreground "blue")) (((class color) (min-colors 88) (background dark)) (:underline (:color foreground-color :style line) :foreground "cyan1")) (((class color) (background dark)) (:underline (:color foreground-color :style line) :foreground "cyan")) (t (:inherit (underline)))))
'(link-visited ((default (:inherit (link))) (((class color) (background light)) (:foreground "magenta4")) (((class color) (background dark)) (:foreground "violet"))))
'(fringe ((((class color) (background light)) (:background "grey95")) (((class color) (background dark)) (:background "grey10")) (t (:background "gray"))))
'(header-line ((default (:inherit (mode-line))) (((type tty)) (:underline (:color foreground-color :style line) :inverse-video nil)) (((class color grayscale) (background light)) (:box nil :foreground "grey20" :background "grey90")) (((class color grayscale) (background dark)) (:box nil :foreground "grey90" :background "grey20")) (((class mono) (background light)) (:underline (:color foreground-color :style line) :box nil :inverse-video nil :foreground "black" :background "white")) (((class mono) (background dark)) (:underline (:color foreground-color :style line) :box nil :inverse-video nil :foreground "white" :background "black"))))
'(tooltip ((((class color)) (:inherit (variable-pitch) :foreground "black" :background "lightyellow")) (t (:inherit (variable-pitch)))))
'(mode-line ((((class color) (min-colors 88)) (:foreground "black" :background "grey75" :box (:line-width -1 :color nil :style released-button))) (t (:inverse-video t))))
'(mode-line-buffer-id ((t (:weight bold))))
'(mode-line-emphasis ((t (:weight bold))))
'(mode-line-highlight ((((class color) (min-colors 88)) (:box (:line-width 2 :color "grey40" :style released-button))) (t (:inherit (highlight)))))
'(mode-line-inactive ((default (:inherit (mode-line))) (((class color) (min-colors 88) (background light)) (:background "grey90" :foreground "grey20" :box (:line-width -1 :color "grey75" :style nil) :weight light)) (((class color) (min-colors 88) (background dark)) (:background "grey30" :foreground "grey80" :box (:line-width -1 :color "grey40" :style nil) :weight light))))
'(isearch ((t (:background "#ffe792" :foreground "#000000"))))
'(isearch-fail ((t (:background "#00a8c6" :foreground "#f8f8f0"))))
'(lazy-highlight ((t (:background "#ffe792" :foreground "#000000"))))
'(match ((t (:background "#ffe792" :foreground "#000000"))))
'(next-error ((t (:inherit (region)))))
'(query-replace ((t (:inherit (isearch)))))
)

(provide-theme 'mellow )

  )
