;;; slack-slash.el --- allow you to invoke your custom slash command via http

;; Copyright (C) 2018  Lih Chen

;; Author: Lih Chen <lihster@gmail.com>
;; Maintainer: Lih Chen <lihster@gmail.com>
;; Created: 1 Jan 2018
;; Version: 0.1.0
;; Url: http://github.com/noitcudni/emacs-slack-slash
;; Keywords: lisp, elisp, slack, slash
;; Package-requires:

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This essentially is an HTTP client that hits the external URL
;; for your customer slash command directly

;; Examples:

;; GET-ing an HTTP page
;;
;; (clj-slack-setup :fun-name norby
;;                  :command "/norby-prod"
;;                  :channel-name "prod"
;;                  :token "your-token"
;;                  :external-url "your-external-url"
;;                  )

;; (require 'web)

;; must have clj-cmd-token in .emacs or .spacemacs
;; (clj-slack-setup :fun-name norby
;;                  :command "/norby-prod"
;;                  :channel-name "prod"
;;                  :token "TODKEN"
;;                  :external-url "URL"
;;                  )

;; (request
;;  "https://subs.swingeducation.com/clj"
;;  :type "POST"
;;  :parser 'json-read
;;  :params '(("token" . "[token goes here]"
;;            ("command" . "/norby-prod")
;;            ("channel_name" . "prod")
;;            ("user_name" . "Lih Chen (spacemacs)")
;;            ("text" . "(+ 1 1)")
;;            )
;;  :success (cl-function
;;            (lambda (&key data &allow-other-keys)
;;              (message "I sent: %S" (assoc-default 'args data))))
;;  )

;;; Code:
(require 'eval-sexp-fu)

(defun get-string-from-file (filePath)
  "Return file content from FILEPATH."
  (with-temp-buffer
    (insert-file-contents filePath)
    (string-trim (buffer-string))))

(defmacro clj-slack-setup (&rest plist)
  "Takes a configuration PLIST and produces a function."
	(let ((fun-name (plist-get plist :fun-name))
				(command (plist-get plist :command))
				(channel-name (plist-get plist :channel-name))
				(user-name (plist-get plist :user-name))
				(token (plist-get plist :token))
				(external-url (plist-get plist :external-url)))
		`(progn
			 (defun ,fun-name ()
				 (interactive)
				 (cl-labels ((slash-cmd (cmd)
																(let ((query-data (make-hash-table :test 'equal)))
																	(puthash 'token ,token query-data)
																	(puthash 'command ,command query-data)
																	(puthash 'channel_name ,channel-name query-data)
																	(puthash 'user_name ,user-name query-data)
																	(puthash 'text cmd query-data)
																	(web-http-post
																	 (lambda (con header data))
																	 :url ,external-url
																	 :data query-data))))
					 (save-excursion
						 (end-of-defun)
						 (backward-sexp)
						 (let ((sexp (thing-at-point 'sexp)))
							 (slash-cmd sexp))))
				 (message "Sent to slack!"))
			 (define-eval-sexp-fu-flash-command ,fun-name
				 (eval-sexp-fu-flash (save-excursion
															 (end-of-defun)
															 (beginning-of-defun)
															 (bounds-of-thing-at-point 'sexp)))))))

(provide 'slack-slash)
;;; slack-slash.el ends here

(defun manual-flash (n)
  "Manual Flash"
  (interactive "P")
  (message "flashed!"))

(define-eval-sexp-fu-flash-command manual-flash
	(eval-sexp-fu-flash (save-excursion
												(end-of-defun)
												(beginning-of-defun)
												(bounds-of-thing-at-point 'sexp))))
