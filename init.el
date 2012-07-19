(setq is-gui (fboundp 'tool-bar-mode))

(if is-gui
    (progn
      ;; slime
      (eval-after-load "slime" 
        '(progn (slime-setup '(slime-repl))))

      (add-to-list 'load-path "~/.emacs.d/slime")
      (require 'slime)
      (slime-setup)))

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))

(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "/usr/local/share/python/")

(if is-gui (set-default-font "-apple-Menlo-medium-normal-normal-*-14-*-*-*-m-0-iso10646-1"))

;; this is no good in the terminal
;;(normal-erase-is-backspace-mode 1)
;;(delete-selection-mode 1)

(setq ring-bell-function 'ignore)
(show-paren-mode 1)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(require 'el-get)

;; local sources
(setq el-get-sources
      '((:name magit
               :after (lambda () (global-set-key (kbd "C-x C-z") 'magit-status)))
        (:name expand-region 
               :type git
               :url "git://github.com/magnars/expand-region.el.git"
               :features expand-region
               :after (lambda() (global-set-key (kbd "C-=") 'er/expand-region)))
	(:name textmate 
	       :type git 
	       :url "git://github.com/defunkt/textmate.el.git"
	       :features textmate
	       :compile "textmate.el"
	       :after (lambda () (textmate-mode)))
        ))


(setq my-packages
      (append
       '(el-get switch-window vkill google-maps nxhtml xcscope color-theme 
                anything python-mode pylookup linum-ex ack gist swank-clojure
                clojure-mode deft markdown-mode auto-complete ac-slime auto-complete-css
                auto-complete-emacs-lisp auto-complete-etags tail popup)
       (mapcar 'el-get-source-name el-get-sources)))

(el-get 'sync my-packages)

(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(setq interpreter-mode-alist (cons '("python" . python-mode) interpreter-mode-alist))
(autoload 'python-mode "python-mode" "Python editing mode." t)

(add-to-list 'load-path "~/.emacs.d/vendor")
(setq-default py-python-command-args '("--pylab" "--colors=Linux"))
(setq-default py-indent-offset 2)
(setq-default indent-tabs-mode nil)
(setq-default py-python-command "/usr/local/share/python/ipython")

(require 'ipython)
(add-hook 'python-mode-hook
          (lambda ()
	    (linum-mode)))

(global-set-key (kbd "s-J") 'join-line)
(global-set-key (kbd "C-x C-f") 'find-file)
(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "s--") 'text-scale-decrease)

;; deft-mode configuration
(require 'deft)
(setq deft-extension "txt")
(setq deft-text-mode 'org-mode)
(setq deft-directory "~/Dropbox/notes")
(setq deft-use-filename-as-title t)

(setq markdown-command "/usr/local/bin/markdown")

;; put temporary files somewhere other than right in with the real files
(defvar user-temporary-file-directory 
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist `(("." . ,user-temporary-file-directory) (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms `((".*" ,user-temporary-file-directory t))) 

;; smooth the mouse scroll wheel scrolling behavior
;; from http://zwell.net/content/emacs.html
(defun smooth-scroll (increment)
  (scroll-up increment) (sit-for 0.05)
  (scroll-up increment) (sit-for 0.02)
  (scroll-up increment) (sit-for 0.02)
  (scroll-up increment) (sit-for 0.05)
  (scroll-up increment) (sit-for 0.06)
  (scroll-up increment))

(global-set-key [(mouse-5)] '(lambda () (interactive) (smooth-scroll 1)))
(global-set-key [(mouse-4)] '(lambda () (interactive) (smooth-scroll -1)))

;; tramp rules
(require 'tramp)
(add-to-list 'tramp-default-proxies-alist
             '("qa9" nil "/ssh:paykroyd@cc.springpadapp.com:"))
(add-to-list 'tramp-default-proxies-alist
             '("log1" nil "/ssh:paykroyd@cc.springpadapp.com:"))
(add-to-list 'tramp-default-proxies-alist
             '("demo-social1" nil "/ssh:paykroyd@cc.springpadapp.com:"))


;; eshell customizations
(setq eshell-path-env "/usr/local/bin:/usr/local/share/python:/usr/bin:/bin:/usr/sbin:/sbin")

(defun url-fetch (url method headers)
  (let* ((url-request-method method)
         (url-request-extra-headers headers))
    (url-retrieve-synchronously url)))

(defvar spring-username "consumer3")
(defvar spring-password "v7ben42a")
(defvar spring-host "http://pete.springpadapp.com/api")

(defun spring-get (path)
  (switch-to-buffer (url-fetch (concat spring-host path) "GET" (cons (cons "X-Spring-Username"  spring-username)
                                                                     (cons (cons "X-Spring-Password" spring-password)
                                                                           '(("X-Spring-Password" . "v7ben42a")
                                                                             ("X-Spring-Client-Version" . "1")
                                                                             ("X-Spring-Client" . "emacs")
                                                                             ("Content-Type" . "application/json; charset=UTF-8"))))))
  (js-mode)
  (font-lock-fontify-buffer))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(add-to-list 'load-path "~/.emacs.d/personal")

(if is-gui (require 'color-theme-pete))
(if is-gui (color-theme-pete))

(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(require 'auto-complete-config)
(ac-config-default)

;; utility function
(defun prettify-json ()
  (interactive)
  (shell-command-on-region 
   (region-beginning) 
   (region-end) 
   "python -m json.tool"
   (current-buffer)
   t))

(global-set-key (kbd "C-h !") 'prettify-json)
