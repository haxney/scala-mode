;;; scala-mode.el --- Major mode for editing Scala code.

;; Copyright (C) 2009 Scala Dev Team at EPFL
;; Authors: See AUTHORS file
;; Keywords: scala languages oop
;; Version: 0.5.99.5

;;; License

;; SCALA LICENSE
;;
;; Copyright (c) 2002-2010 EPFL, Lausanne, unless otherwise specified.
;; All rights reserved.
;;
;; This software was developed by the Programming Methods Laboratory of the
;; Swiss Federal Institute of Technology (EPFL), Lausanne, Switzerland.
;;
;; Permission to use, copy, modify, and distribute this software in source
;; or binary form for any purpose with or without fee is hereby granted,
;; provided that the following conditions are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in the
;;       documentation and/or other materials provided with the distribution.
;;
;;    3. Neither the name of the EPFL nor the names of its contributors
;;       may be used to endorse or promote products derived from this
;;       software without specific prior written permission.
;;
;;
;; THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;; CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
;; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;; SUCH DAMAGE.


;;; Commentary:
;;

;;; Code:

(require 'cl)

(require 'scala-mode-constants)
(require 'scala-mode-variables)
(require 'scala-mode-lib)
(require 'scala-mode-navigation)
(require 'scala-mode-indent)
(require 'scala-mode-fontlock)
(require 'scala-mode-ui)
(require 'scala-mode-feature)

;;; Customization and Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgroup scala nil
  "Mode for editing Scala code."
  :group 'languages)

(defcustom scala-mode:api-url "http://www.scala-lang.org/docu/files/api/index.html"
  "URL to the online Scala documentation."
  :type 'string
  :group 'scala)

(defconst scala-mode-version "0.5.99.5")
(defconst scala-mode-svn-revision "$Revision: 21917 $")
(defconst scala-bug-e-mail "scala@listes.epfl.ch")
(defconst scala-web-url "http://scala-lang.org/")

;;; Helper functions/macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun scala-mode:browse-web-site ()
  "Browse the Scala home-page."
  (interactive)
  (require 'browse-url)
  (browse-url scala-web-url))

(defun scala-mode:browse-api ()
  "Browse the Scala API."
  (interactive)
  (require 'browse-url)
  (browse-url scala-mode:api-url))

(defun scala-mode:report-bug ()
  "Report a bug to the author of the Scala mode via e-mail.
The package used to edit and send the e-mail is the one selected
through `mail-user-agent'."
  (interactive)
  (require 'reporter)
  (let ((reporter-prompt-for-summary-p t))
    (reporter-submit-bug-report
     scala-bug-e-mail
     (concat "Emacs Scala mode v" scala-mode-version)
     '(scala-indent-step))))

(defvar scala-mode-abbrev-table (make-abbrev-table)
  "Abbrev table in use in `scala-mode' buffers.")

(defvar scala-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; strings and character literals
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)

    ;; different kinds of "parenthesis"
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\] ")[" table)
    (modify-syntax-entry ?\} "){" table)

    ;; special characters
    (modify-syntax-entry ?\_ "_" table)

    (dolist (char scala-all-special-chars)
      (modify-syntax-entry char "." table))

    (modify-syntax-entry ?\. "." table)

    ;; comments
    ;; the `n' means that comments can be nested
    (modify-syntax-entry ?\/  ". 124nb" table)
    (modify-syntax-entry ?\*  ". 23n"   table)
    (modify-syntax-entry ?\n  "> bn" table)
    (modify-syntax-entry ?\r  "> bn" table)
    table)
  "Syntax table used in `scala-mode' buffers.")

;;;###autoload
(define-derived-mode scala-mode prog-mode "Scala"
  "Major mode for editing Scala code.
\\{scala-mode-map}"
  :group 'scala
  (set (make-local-variable 'font-lock-defaults)         '(scala-font-lock-keywords
                                                           nil
                                                           nil
                                                           ((?\_ . "w"))
                                                           nil
                                                           (font-lock-syntactic-keywords . scala-font-lock-syntactic-keywords)
                                                           (parse-sexp-lookup-properties . t)))

  (set (make-local-variable 'paragraph-separate)           (concat "^\\s *$\\|" page-delimiter))
  (set (make-local-variable 'paragraph-start)              (concat "^\\s *$\\|" page-delimiter))
  (set (make-local-variable 'paragraph-ignore-fill-prefix) t)
  (set (make-local-variable 'require-final-newline)        t)
  (set (make-local-variable 'comment-start)                "// ")
  (set (make-local-variable 'comment-end)                  "")
  (set (make-local-variable 'comment-start-skip)           "/\\*+ *\\|//+ *")
  (set (make-local-variable 'comment-end-skip)             " *\\*+/\\| *")
  (set (make-local-variable 'comment-column)               40)
  ;; (set (make-local-variable 'comment-indent-function)   'scala-comment-indent-function)
  (set (make-local-variable 'indent-line-function)         'scala-indent-line)
  (scala-mode-feature-install))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode))
;;;###autoload
(modify-coding-system-alist 'file "\\.scala$"     'utf-8)

(provide 'scala-mode)

;;; scala-mode.el ends here
