;;; unity3d.el --- minor mode for Frostbite Projects -*- Mode: Emacs-Lisp -*-

(require 'dired-aux)

(defcustom unity3d-current-project "TestProject"
  "The name of your current unity3d project"
  :type 'string
  :group 'unity3d)

(defcustom unity3d-project-root "c:/users/dsthilaire/documents/"
  "The path to your project root"
  :type 'string
  :group 'unity3d)


(defcustom unity3d-documentation-folder "c:/Program Files/Unity/Editor/Data/Documentation/"
  "Unity3d local documentation folder"
  :type 'string
  :group 'unity3d)

(defcustom unity3d-browser-cmd "start chrome"
  "Unity3d command to open documentation browser"
  :type 'string
  :group 'unity3d)

(setq unity3d-rgrep-asset-folder (concat unity3d-project-root "/" unity3d-current-project "/Assets"))
;;(setq unity3d-rgrep-source-folder (concat unity3d-rgrep-asset-folder "/_Scripts"))
(setq unity3d-rgrep-source-folder (concat unity3d-rgrep-asset-folder))
(setq unity3d-rgrep-unity3d-extensions "*.cs")
(setq unity3d-find-name-dired-default-dir (concat unity3d-rgrep-source-folder "/"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unity3d searching

(defun unity3d-current-word-or-region ()
  (if (use-region-p)
(buffer-substring (region-beginning) (region-end))
(current-word)))

;; (defun unity3d-rgrep-fast (searched-str)
;;   (concat "rgrep symbol in " unity3d-current-project)
;;   (interactive (list (let* ((word (unity3d-current-word-or-region))
;; (input (read-string (concat "Search " unity3d-current-project "(default: \"" word "\"): ") nil 'unity3d-grep-history)))
;; (if (string= input "") word input))))
;;   (grep-compute-defaults)
;;   (rgrep searched-str unity3d-rgrep-unity3d-extensions unity3d-rgrep-source-folder)
;;   (select-window (next-window))
;;   (delete-other-windows)
;;   (sleep-for 1.0)
;;   (search-forward "/dev/null")
;;   (next-line)
;;   (beginning-of-line))

;; (defun unity3d-rgrep (searched-str path)
;;   "rgrep symbol in Engine codebase."
;;   (interactive (list (let* ((word (unity3d-current-word-or-region))
;; (input (read-string (concat "Search for (default: \"" word "\"): ") nil 'unity3d-grep-history))) 
;; (if (string= input "") word input))
;; (let* ((default-path (concat unity3d-rgrep-source-folder "/Engine"))
;; (input (read-directory-name (concat "Module Folder (default Engine)") default-path)))
;; (if (string= input "") default-path input))))
;;   (grep-compute-defaults)
;;   (rgrep searched-str unity3d-rgrep-unity3d-extensions path)
;;   (select-window (next-window))
;;   (delete-other-windows)
;;   )

(defun unity3d-find-name-dired (pattern &optional dir)
  "Wrapper over find-name-dired that takes the pointed word as default pattern"
  (interactive (let ((pattern (read-string "Pattern: " (concat "*" (unity3d-current-word-or-region) "*") 'unity3d-find-name-dired-history))
(dir (read-directory-name "Path: " unity3d-find-name-dired-default-dir)))
(list pattern dir)))

  (let ((fixed-dir (if dir dir unity3d-find-name-dired-default-dir)))
(find-name-dired fixed-dir pattern)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unity3d utils

;; todo
;; (defun unity3d-next-buffer ()
;; "Cycle to next open buffer"
;; (interactive)
;; )

;;
(defun unity3d-find-doc (pattern)
  "Tries to find documentation on the given string sequence. Then mark file with 'm', then '!' to execute the 'start chrome' command on it."
  (interactive
  (let* ((word (unity3d-current-word-or-region))
         (input (read-string (concat "Search doc: ") word 'unity3d-find-doc-history)))
    (list (if (string= input "") word input))))
  (unity3d-find-name-dired (concat pattern ".html") unity3d-documentation-folder)
  ;(unity3d-find-name-dired (concat pattern ".txt") unity3d-documentation-folder)

  (sleep-for 1)
  (let ((filecount (dired-mark-files-regexp ".*")))
    (if (= filecount 1)
        (unity3d-dired-open-marked-files)
      (dired-unmark-all-files 13))))

(defun unity3d-dired-open-marked-files ()
  (interactive)
  (let ((marked-files (dired-get-marked-files)))

  ;; mark current file if no files are marked
  (when (= (length marked-files) 0)
  (dired-mark nil)
  (setq marked-files (dired-get-marked-files)))

  (dolist (file marked-files)
    (dired-shell-command (concat unity3d-browser-cmd " \"" file "\""))
    ;;(find-file file)
    ))

  ;; 13 corresponds to the default char returned by the interactive command
  (dired-unmark-all-files 13)
  (kill-buffer (current-buffer)))

(defvar unity3d-doc-codesearch-data nil)
(defun unity3d-gen-doc-codesearch-data ()
  'todo)

(defun unity3d-search-doc (pattern case-sensitive?)
  "Tries to find documentation on the given string sequence. Then mark file with 'm', then '!' to execute the 'start chrome' command on it."
  (interactive
   (let* ((word (unity3d-current-word-or-region))
          (input (read-string (concat "Search doc: ") word 'unity3d-find-doc-history))
          (is-case-sensitive? (y-or-n-p "case sensitive? ")))
     (list (if (string= input "") word input) is-case-sensitive?)))
                                        ;(unity3d-find-name-dired (concat pattern ".html") unity3d-documentation-folder)
  (let ((codesearch-global-data unity3d-doc-codesearch-data))
    (codesearch pattern case-sensitive?)))

(defvar unity3d-mode-map
  (let ((map (make-sparse-keymap)))
    ;;(define-key map (kbd "<C-M-backspace>") 'unity3d-rgrep)
    (define-key map (kbd "<C-=>") 'unity3d-find-doc)
    (define-key map (kbd "<C-return>") 'unity3d-search-doc)
    ;; (define-key map (kbd "<C-M-return>") 'unity3d-rgrep-fast)
    ;; (define-key map (kbd "C-M-'") 'unity3d-find-name-dired)
    (define-key map (kbd "M-o") 'switch-to-prev-buffer)
    (define-key map (kbd "C-M-o") 'switch-to-next-buffer)

    ;;(define-key dired-mode-map (kbd "M-o") 'unity3d-dired-open-marked-files)

    map)
  "unity3d-mode keymap.")

(define-minor-mode unity3d-mode
  "Toggle unity3d mode."
  :init-value nil
  :global nil
  :lighter " unity3d"
  :keymap 'unity3d-mode-map
  :group 'unity3d
  (use-local-map unity3d-mode-map))

(add-hook 'unity3d-mode-hook (lambda ()
(if unity3d-mode
(define-key dired-mode-map (kbd "M-o") 'unity3d-dired-open-marked-files)
(define-key dired-mode-map (kbd "M-o") nil))))

(provide 'unity3d)
