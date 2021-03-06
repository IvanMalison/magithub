;;; magithub-tests.el --- tests for Magithub

;; Copyright (C) 2016  Sean Allred
;;
;; License: GPLv3

;;; Code:

(require 'ert)

(add-to-list 'load-path ".")

(ert-deftest magithub-test-compile ()
  (should (byte-compile-file "magithub-core.el"))
  (should (byte-compile-file "magithub-issue.el"))
  (should (byte-compile-file "magithub-ci.el"))
  (should (byte-compile-file "magithub.el")))

;;; magithub-test.el ends here
