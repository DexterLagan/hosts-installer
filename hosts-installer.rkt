#lang racket/gui
(require net/url)

;;; purpose

; to install winhelp2002's hosts file as quickly and painlessly as possible.
; currently the program has to be run as administrator
; in the future program will ask administrator permissions to backup and replace the hosts file in Windows' system folder.

;;; version history

; v1.1 - added support for exception handling
;      - 
; v1.0 - initial release. Has to be run as administrator.

;;; consts

(define *appname*     "Hosts Installer v1.1")
(define hosts-url-str "https://winhelp2002.mvps.org/hosts.txt")
(define target-path   "C:\\Windows\\System32\\Drivers\\etc\\HOSTS")
(define backup-path   "C:\\Windows\\System32\\Drivers\\etc\\HOSTS.MVP")
(define exists-ok     #t)

;;; defs

;; reads the contents of a URL and returns is as a string
(define (url-to-string url-str)
  (define url (string->url url-str))
  (define in (get-pure-port url #:redirections 5))
  (define response-string (port->string in))
  (close-input-port in)
  response-string)

;; quick die
(define (die msg)
  (message-box *appname* msg #f (list 'ok 'caution))
  (exit 1))

;;; main

; read host file content from the Web
(define hosts-content (url-to-string hosts-url-str))

; if hosts file is where we expect, back it up and update it
(if (file-exists? target-path)
    (begin (with-handlers ([exn:fail:filesystem?
                            (λ (e) (die "Unable to create backup file. Access denied. Please run this program as Administrator."))])
             (copy-file target-path backup-path exists-ok))
           (with-handlers ([exn:fail:filesystem?
                            (λ (e) (die "Unable to write hosts file. Access denied. Please run this program as Administrator."))])
             (display-to-file hosts-content target-path #:exists 'replace))
           (message-box *appname* "Hosts file installed successfully.  "))
    (message-box *appname* "Error installing hosts file. Target file not found.  " #f (list 'ok 'caution)))

(exit 0)


; EOF










