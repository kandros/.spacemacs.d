(defun frame-geometry//save ()
  "Gets the current frame's geometry and saves to ~/.emacs.d/frame-geometry."
  (let* ((frame-size (alist-get 'outer-size (frame-geometry (selected-frame))))
         (frame-geometry-left (frame-parameter (selected-frame) 'left))
         (frame-geometry-top (frame-parameter (selected-frame) 'top))
         (frame-geometry-width (car frame-size))
         (frame-geometry-height (cdr frame-size)))

    (when (not (number-or-marker-p frame-geometry-left))
      (setq frame-geometry-left 0))
    (when (not (number-or-marker-p frame-geometry-top))
      (setq frame-geometry-top 0))
    (when (not (number-or-marker-p frame-geometry-width))
      (setq frame-geometry-width 0))
    (when (not (number-or-marker-p frame-geometry-height))
      (setq frame-geometry-height 0))

    (with-temp-buffer
      (insert
       ";;; This is the previous emacs frame's geometry.\n"
       ";;; Last generated " (current-time-string) ".\n"
       (format "(add-to-list 'initial-frame-alist '(top . %d))\n" (max frame-geometry-top 0))
       (format "(add-to-list 'initial-frame-alist '(left . %d))\n" (max frame-geometry-left 0))
       ;; For some reason, we're about 20x4px off, so adjust
       (format "(add-to-list 'initial-frame-alist '(width . (text-pixels . %d)))\n" (max (- frame-geometry-width 20) 0))
       (format "(add-to-list 'initial-frame-alist '(height . (text-pixels . %d)))\n" (max (- frame-geometry-height 4) 0)))
      (when (file-writable-p frame-geometry-file)
        (write-file frame-geometry-file)))))

(defun frame-geometry//load ()
  "Loads ~/.emacs.d/frame-geometry which should load the previous frame's
geometry."
  (when (file-readable-p frame-geometry-file)
    (load-file frame-geometry-file)))
