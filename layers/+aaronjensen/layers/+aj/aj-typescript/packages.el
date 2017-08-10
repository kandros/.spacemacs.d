;;; packages.el --- aj-typescript layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Aaron Jensen <aaronjensen@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;

;;; Code:

(defconst aj-typescript-packages
  '(tide
    typescript-mode
    prettier-js))

(defun aj-typescript/post-init-prettier-js ()
  (add-hook 'typescript-mode-hook 'prettier-js-mode t)
  (add-hook 'web-mode-hook 'prettier-js-mode t))

(defun aj-typescript/post-init-tide ()
  (with-eval-after-load 'tide
    (spacemacs/set-leader-keys-for-minor-mode 'tide-mode "f" #'tide-fix)))


(defun aj-typescript/post-init-typescript-mode ()
  (setq typescript-indent-level 2)

  (with-eval-after-load 'typescript-mode
    (modify-syntax-entry ?_ "w" typescript-mode-syntax-table)))
;;; packages.el ends here
