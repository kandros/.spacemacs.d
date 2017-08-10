(add-hook 'scss-mode-hook (lambda ()
                            (setq-local company-backends '((company-css company-dabbrev-code company-gtags)))))
(add-hook 'scss-mode-hook 'stylefmt-enable-on-save)
(with-eval-after-load 'css-mode (require 'stylefmt))

(provide 'init-sass)
