(require 'dash)

(defun org-keys ()
  (interactive)
  ;; Make ~SPC ,~ work, reference:
  ;; http://stackoverflow.com/questions/24169333/how-can-i-emphasize-or-verbatim-quote-a-comma-in-org-mode
  (setcar (nthcdr 2 org-emphasis-regexp-components) " \t\n")
  (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)

  (setq org-emphasis-alist '(("*" bold)
                             ("/" italic)
                             ("_" underline)
                             ("=" org-verbatim verbatim)
                             ("~" org-kbd)
                             ("+"
                              (:strike-through t))))

  (setq org-hide-emphasis-markers t))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "M-h") 'org-metaleft)
  (define-key org-mode-map (kbd "M-j") 'org-metadown)
  (define-key org-mode-map (kbd "M-k") 'org-metaup)
  (define-key org-mode-map (kbd "M-l") 'org-metaright)
  (define-key org-mode-map (kbd "M-H") 'org-shiftmetaleft)
  (define-key org-mode-map (kbd "M-J") 'org-shiftmetadown)
  (define-key org-mode-map (kbd "M-K") 'org-shiftmetaup)
  (define-key org-mode-map (kbd "M-L") 'org-shiftmetaright)
  (org-keys)

  (require 'org-inlinetask)
  (define-key org-mode-map (kbd "RET")
    'aj/org-return)
  (define-key org-mode-map (kbd "<backspace>")
    'aj/org-delete-backward-char)

  (add-to-list 'org-log-note-headings '(note . "%t")))

(spacemacs/set-leader-keys "bo" 'org-iswitchb)
(spacemacs/set-leader-keys "oh" 'aj/counsel-org-file-headlines)
(spacemacs/set-leader-keys "oH" 'counsel-org-agenda-headlines)

(setq org-log-into-drawer "LOGBOOK")
(setq org-mobile-force-id-on-agenda-items nil)
(setq org-startup-indented t)
(setq org-agenda-todo-ignore-scheduled t)
(setq org-agenda-todo-ignore-deadlines t)
(setq org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))
(setq org-agenda-sticky t)
(setq org-export-html-postamble nil)
(setq org-M-RET-may-split-line '((default . nil)))

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "|" "CANCELLED(c@/!)"))))


(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "#F92672" :weight bold)
              ("DONE" :foreground "#A6E22E" :weight bold)
              ("WAITING" :foreground "#FD971F" :weight bold)
              ("CANCELLED" :foreground "#A6E22E" :weight bold))))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              (done ("WAITING"))
              ("TODO" ("WAITING") ("CANCELLED"))
              ("DONE" ("WAITING") ("CANCELLED")))))

(setq org-use-fast-todo-selection t)

(add-hook 'org-capture-mode-hook 'evil-insert-state)
(add-hook 'org-log-buffer-setup-hook 'evil-insert-state)

;; Refresh calendars via org-gcal and automatically create appt-reminders.
;; Appt will be refreshed any time an org file is saved after 10 seconds of idle.
;; gcal will be synced after 1 minute of idle every 15 minutes.
;; Start with `(aj-sync-calendar-start)'
(defvar aj-refresh-appt-timer nil
  "Timer that `aj-refresh-appt-with-delay' uses to reschedule itself, or nil.")
(defun aj-refresh-appt-with-delay ()
  (when aj-refresh-appt-timer
    (cancel-timer aj-refresh-appt-timer))
  (setq aj-refresh-appt-timer
        (run-with-idle-timer
         10 nil
         (lambda ()
           (setq appt-time-msg-list nil)
           (let ((inhibit-message t))
             (org-agenda-to-appt))))))

(defvar aj-sync-calendar-timer nil
  "Timer that `aj-sync-calendar-with-delay' uses to reschedule itself, or nil.")
(defun aj-sync-calendar-with-delay ()
  (when aj-sync-calendar-timer
    (cancel-timer aj-sync-calendar-timer))
  (setq aj-sync-calendar-timer
        (run-with-idle-timer
         60 nil
         (lambda ()
           (let ((inhibit-message t))
             (require 'org-gcal)
             (org-gcal-refresh-token)
             (org-gcal-fetch))))))

(defun aj-sync-calendar-start ()
  (add-hook 'after-save-hook
            (lambda ()
              (when (eq major-mode 'org-mode)
                (aj-refresh-appt-with-delay))))

  (run-with-timer
   0 (* 15 60)
   'aj-sync-calendar-with-delay))

(defun aj/org-save-all-org-buffers (&rest _)
  (org-save-all-org-buffers))
(advice-add 'org-agenda-quit :before 'aj/org-save-all-org-buffers)
(advice-add 'org-agenda-todo :after 'aj/org-save-all-org-buffers)
(advice-add 'org-agenda-deadline :after 'aj/org-save-all-org-buffers)
(advice-add 'org-agenda-schedule :after 'aj/org-save-all-org-buffers)
(advice-add 'org-agenda-refile :after 'aj/org-save-all-org-buffers)
(advice-add 'org-refile :after 'aj/org-save-all-org-buffers)

;; Custom org-agenda view
(setq org-agenda-compact-blocks t)
(setq org-agenda-custom-commands
      (quote ((" " "Agenda"
               ((agenda "" ((org-agenda-span 'day)))
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-REFILE/!"
                           ((org-agenda-overriding-header "Tasks")
                            (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'aj/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))))))

(defun aj/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (save-restriction
    (widen)
    ;; Consider only tasks with done todo headings as archivable candidates
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
          (subtree-end (save-excursion (org-end-of-subtree t))))
      (if (member (org-get-todo-state) org-todo-keywords-1)
          (if (member (org-get-todo-state) org-done-keywords)
              (let* ((daynr (string-to-number (format-time-string "%d" (current-time))))
                     (a-month-ago (* 60 60 24 (+ daynr 1)))
                     (last-month (format-time-string "%Y-%m-" (time-subtract (current-time) (seconds-to-time a-month-ago))))
                     (this-month (format-time-string "%Y-%m-" (current-time)))
                     (subtree-is-current (save-excursion
                                           (forward-line 1)
                                           (and (< (point) subtree-end)
                                                (re-search-forward (concat last-month "\\|" this-month) subtree-end t)))))
                (if subtree-is-current
                    subtree-end ; Has a date in this month or last month, skip it
                  nil))  ; available to archive
            (or subtree-end (point-max)))
        next-headline))))

(defun aj/persp-org-agenda (&optional arg)
  "Show my custom agenda and refresh it first chance we get."
  (interactive "P")
  (persp-switch "@Agenda")
  (if-let (window (get-buffer-window "*Org Agenda( )*"))
      (select-window window)
    (let ((org-agenda-window-setup 'only-window))
      (org-agenda arg " ")))
  (run-with-idle-timer 1 nil 'org-agenda-redo))

;; org-refile settings
(defun aj/refile-target-files ()
  (let ((exclude (and
                  (boundp 'org-gcal-file-alist)
                  (-map 'cdr org-gcal-file-alist))))
    (-reject (lambda (file) (-contains-p exclude file))
             (org-agenda-files))))

(setq org-refile-targets '((nil :maxlevel . 9)
                           (aj/refile-target-files :maxlevel . 3)))
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes 'confirm)

(defun aj/verify-refile-target ()
  "Exclude todo keywords with a done state and org-gcal files"
  (and (not (member (nth 2 (org-heading-components)) org-done-keywords))
       (not (member buffer-file-name (mapcar #'cdr org-gcal-file-alist)))))

(setq org-refile-target-verify-function 'aj/verify-refile-target)

;; org-capture settings
(setq org-capture-templates
      '(("n" "Notes" entry
         (file (concat org-directory "/refile.org"))
         "* %? :NOTE:\n%U\n%a")
        ("t" "Todo" entry
         (file (concat org-directory "/refile.org"))
         "* TODO %?\n%U\n%a")
        ("s" "Scheduled Task" entry
         (file (concat org-directory "/refile.org"))
         "* TODO %?\nSCHEDULED: %^{When}t")))

(setq org-projectile:capture-template "* TODO %?\n%U\n%a")

;; gnuplot settings
(advice-add 'org-plot/gnuplot :after #'org-redisplay-inline-images)

;; https://lists.gnu.org/archive/html/emacs-orgmode/2017-04/msg00062.html
(with-eval-after-load 'org-mobile
  (defun org-mobile-get-outline-path-link (pom)
    (org-with-point-at pom
      (concat "olp:"
              (org-mobile-escape-olp (file-name-nondirectory buffer-file-name))
              ":"
              (mapconcat 'org-mobile-escape-olp
                         (org-get-outline-path)
                         "/")
              "/"
              (org-mobile-escape-olp (nth 4 (org-heading-components)))))))

(defun string-before-p (string)
  "Return t if string before `point' equals STRING."
  (let ((start (- (point) (length string))))
    (and (>= start (point-min))
         (string-equal
          (buffer-substring-no-properties start (point))
          string))))

(defun aj/org-delete-backward-char (&optional n)
  "Delete checkboxes, list item bullets and demote headlines."
  (interactive "P")
  (cond
   (n
    (org-delete-backward-char n))
   ((org-at-item-p)
    (let ((point (point))
          (bullet-beginning (match-beginning 1))
          (bullet-end (match-end 1)))
      (cond
       ;; If we are near the end of the bullet...
       ((or (eql bullet-end point)
            (eql bullet-end (- point 1)))
        ;; See if we are in a nested list...
        (if (save-excursion
              (goto-char bullet-end)
              (eql
               'item
               (car
                (org-element-property
                 :parent
                 (org-element-property :parent (org-element-context))))))
            ;; And if so, outdent
            (org-metaleft)
          ;; Otherwise, delete the bullet
          (delete-region bullet-beginning point)))
       ;; If we are near the end of a checkbox...
       ((and (org-at-item-checkbox-p)
             (or (eql (match-end 1) point)
                 (eql (match-end 1) (- point 1))))
        ;; Delete the entire checkbox
        (delete-region (match-beginning 1) point))
       (t
        (org-delete-backward-char 1)))))
   ((eq 'headline (car (org-element-context)))
    (cond
     ;; Delete top level headline *, including trailing space
     ((looking-back "^\\* " 0)
      (org-ctrl-c-star))
     ;; Promote headline
     ((looking-back "^\\*\\*+ " 0)
      (org-metaleft))
     ;; Otherwise, delete normally
     (t
      (org-delete-backward-char 1))))
   ;; Normal delete
   (t
    (org-delete-backward-char 1))))

(defun aj/org-in-empty-item ()
  "Return t if in an empty list item, nil otherwise."
  (save-excursion
    (beginning-of-line)
    (looking-at (concat (org-item-re) " ?$"))))

;; via http://kitchingroup.cheme.cmu.edu/blog/2017/04/09/A-better-return-in-org-mode/
(defun aj/org-return (&optional ignore)
  "Add new list item, heading or table row with RET.
A double return on an empty element deletes it.
Use a prefix arg to get regular RET. "
  (interactive "P")
  (if ignore
      (org-return)
    (cond
     ;; Break lines like normal
     ((eq 'line-break (car (org-element-context)))
      (org-return-indent))
     ;; Open links like usual
     ((and (eq 'link (car (org-element-context))) (not (eolp)))
      (org-open-at-point-global))
     ;; It doesn't make sense to add headings in inline tasks. Thanks Anders
     ;; Johansson!
     ((org-inlinetask-in-task-p)
      (org-return))
     ;; add checkboxes
     ((org-at-item-checkbox-p)
      (org-insert-todo-heading nil))
     ;; If we are in an item and not at the beginning of the line...
     ((and (org-in-item-p) (not (bolp)))
      (if (aj/org-in-empty-item)
          ;; Delete the bullet
          (delete-region (line-beginning-position) (line-end-position))
        ;; Insert a new bullet
        (org-insert-heading)))
     ((org-at-heading-p)
      (if (not (string= "" (org-element-property :title (org-element-context))))
          (org-meta-return)
        (beginning-of-line)
        (setf (buffer-substring
               (line-beginning-position) (line-end-position)) "")))
     ((and (org-at-table-p)
           (org-table-check-inside-data-field t))
      (if (-any?
           (lambda (x) (not (string= "" x)))
           (nth
            (org-table-current-dline)
            (org-table-to-lisp)))
          (org-return)
        ;; empty row
        (beginning-of-line)
        (setf (buffer-substring
               (line-beginning-position) (line-end-position)) "")
        (org-return)))
     (t
      (org-return)))))

;; From https://github.com/jkitchin/scimax/blob/master/scimax-org.el
(defun aj/counsel-org-file-headlines ()
  "Jump to heading in the current buffer."
  (interactive)
  (let ((headlines '()))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward
              ;; this matches org headings in elisp too.
              "^\\(;; \\)?\\(\\*+\\)\\(?: +\\(.*?\\)\\)?[ 	]*$"  nil t)
        (cl-pushnew (list
                     (format "%-80s"
                             (match-string 0))
                     (cons 'position (match-beginning 0)))
                    headlines)))
    (ivy-read "Headline: "
              (reverse headlines)
              :action (lambda (candidate)
                        (org-mark-ring-push)
                        (goto-char (cdr (assoc 'position candidate)))
                        (outline-show-entry)))))

;; Recalculate buffer tables on save
(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'org-table-recalculate-buffer-tables nil t)))

(provide 'init-org)
