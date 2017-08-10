(defun aj/select-text (text)
  (if (display-graphic-p)
      (gui-select-text text)
    (require 'xclip)
    (xclip-select-text text)))

(defun aj/selection-value ()
  (if (display-graphic-p)
      (gui-selection-value)
    (require 'xclip)
    (xclip-selection-value)))

(setq interprogram-cut-function 'aj/select-text
      interprogram-paste-function 'aj/selection-value)

(provide 'init-xclip)
