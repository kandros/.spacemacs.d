(require 'evil-terminal-cursor-changer)
(defun etcc--make-iterm-tmux-shape-seq (shape)
  (let ((prefix "\e[")
        (suffix " q")
        (box "0")
        (bar "3"))
        (case shape
                ('box (concat prefix box suffix))
                ('bar (concat prefix bar suffix)))))

(defadvice etcc--make-cursor-shape-seq (around iterm-with-tmux (shape))
  ""
  (if (and (etcc--in-iterm?)
           (etcc--in-tmux?))
      (setq ad-return-value (etcc--make-iterm-tmux-shape-seq shape))
    ad-do-it))

(ad-activate 'etcc--make-cursor-shape-seq)

(defadvice etcc--apply-to-terminal (around fix-is-not-termcap (seq))
  ""
  (unless (display-graphic-p)
     ad-do-it))
(ad-activate 'etcc--apply-to-terminal)

(advice-add #'etcc--in-iterm? :around
            (lambda (f)
              (string= (getenv "TERM_PROGRAM" (selected-frame)) "iTerm.app")))

(advice-add #'etcc--in-tmux? :around
            (lambda (f)
              (getenv "TMUX" (selected-frame))))

(evil-terminal-cursor-changer-activate)
(provide 'init-terminal-cursor)
