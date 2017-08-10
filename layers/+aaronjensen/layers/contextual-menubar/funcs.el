(defun contextual-menubar/show-or-hide-menubar (&optional frame)
  "Display the menubar in FRAME (default: selected frame) if on a
    graphical display, but hide it if in terminal."
  (interactive)
  (set-frame-parameter frame 'menu-bar-lines
                       (if (display-graphic-p frame)
                           1 0)))
