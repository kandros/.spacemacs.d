;; Unaccepted fix for http://debbugs.gnu.org/cgi/bugreport.cgi?bug=21559
;; Based on the more simple https://debbugs.gnu.org/cgi/bugreport.cgi?bug=21559#74

(with-eval-after-load 'vc-git
  (defun vc-git-conflicted-files (directory)
    "Return the list of files with conflicts in DIRECTORY."
    (let* ((status
            (vc-git--run-command-string directory "diff-files"
                                        "--name-status"))
           (lines (when status (split-string status "\n" 'omit-nulls)))
           files)
      ;; TODO: Look into reimplementing `vc-git-state', as well as

      ;; `vc-git-dir-status-files', based on this output, thus making the

      ;; extra process call in `vc-git-find-file-hook' unnecessary.

      (dolist (line lines files)
        (when (string-match "\\([ MADRCU?!]\\)[ \t]+\\(.+\\)" line)
          (let ((state (match-string 1 line))
                (file (match-string 2 line)))
            ;; See git-status(1).

            (when (equal state "U")
              (push (expand-file-name file directory) files))))))))
