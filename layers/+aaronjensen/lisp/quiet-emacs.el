;; via http://pragmaticemacs.com/emacs/make-emacs-a-bit-quieter/
(setq auto-revert-verbose nil)

;; custom autosave to suppress messages
;;
;; For some reason `do-auto-save' doesn't work if called manually
;; after switching off the default autosave altogether. Instead set
;; to a long timeout so it is not called.
(setq auto-save-timeout 99999)

;; Set up my timer
(defvar aj/auto-save-timer nil
  "Timer to run `aj/auto-save-silent'")

;; Auto-save every 5 seconds of idle time
(defvar aj/auto-save-interval 5
  "How often in seconds of idle time to auto-save with `aj/auto-save-silent'")

;; Function to auto save files silently
(defun aj/auto-save-silent ()
  "Auto-save all buffers silently"
  (interactive)
  (do-auto-save t))

;; Start new timer
(setq aj/auto-save-timer
      (run-with-idle-timer 0 aj/auto-save-interval 'aj/auto-save-silent))

(provide 'quiet-emacs)
