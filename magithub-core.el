;;; magithub-core.el --- core functions for magithub  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Sean Allred

;; Author: Sean Allred <code@seanallred.com>
;; Keywords: tools

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

;;; Code:

(require 'magit)

(defun magithub-github-repository-p ()
  "Non-nil if \"origin\" points to GitHub."
  (let ((url (magit-get "remote" "origin" "url")))
    (or (s-prefix? "git@github.com:" url)
        (s-prefix? "https://github.com/" url)
        (s-prefix? "git://github.com/" url))))

(defun magithub--completing-read-multiple (prompt collection)
  "Using PROMPT, get a list of elements in COLLECTION.
This function continues until all candidates have been entered or
until the user enters a value of \"\".  Duplicate entries are not
allowed."
  (let (label-list this-label done)
    (while (not done)
      (setq collection (remove this-label collection)
            this-label "")
      (when collection
        ;; @todo it would be nice to detect whether or not we are
        ;; allowed to create labels -- if not, we can require-match
        (setq this-label (completing-read prompt collection)))
      (unless (setq done (s-blank? this-label))
        (push this-label label-list)))
    label-list))

(defconst magithub-hash-regexp
  (rx bow (= 40 (| digit (any (?A . ?F) (?a . ?f)))) eow)
  "Regexp for matching commit hashes.")

(defcustom magithub-hub-executable "hub"
  "The hub executable used by Magithub."
  :group 'magithub
  :package-version '(magithub . "0.1")
  :type 'string)

(defvar magithub-debug-mode nil
  "When non-nil, echo hub commands before they're executed.")

(defmacro magithub-with-hub (&rest body)
  `(let ((magit-git-executable magithub-hub-executable)
         (magit-pre-call-git-hook nil)
         (magit-git-global-arguments nil))
     ,@body))

(defun magithub--hub-command (magit-function command args)
  (unless (executable-find magithub-hub-executable)
    (user-error "Hub (hub.github.com) not installed; aborting"))
  (unless (file-exists-p "~/.config/hub")
    (user-error "Hub hasn't been initialized yet; aborting"))
  (when magithub-debug-mode
    (message "Calling hub with args: %S %S" command args))
  (magithub-with-hub (funcall magit-function command args)))

(defun magithub--command (command &optional args)
  "Run COMMAND synchronously using `magithub-hub-executable'."
  (magithub--hub-command #'magit-run-git command args))

(defun magithub--command-with-editor (command &optional args)
  "Run COMMAND asynchronously using `magithub-hub-executable'.
Ensure GIT_EDITOR is set up appropriately."
  (magithub--hub-command #'magit-run-git-with-editor command args))

(defun magithub--command-output (command &optional args)
  "Run COMMAND synchronously using `magithub-hub-executable'
and returns its output as a list of lines."
  (magithub-with-hub (magit-git-lines command args)))

(defun magithub--command-quick (command &optional args)
  "Quickly execute COMMAND with ARGS."
  (ignore (magithub--command-output command args)))

(provide 'magithub-core)
;;; magithub-core.el ends here
