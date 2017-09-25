;;; ERC

(require 'erc nil t)
;; (require 'znc)
(require 'erc-match nil t)
(require 'festival nil t)

(global-set-key "\C-crerc" 'my-erc-edit-erc-auth)
(global-set-key "\C-crerC" 'my-erc-edit-audience-erc)
(global-set-key "\C-c\C-sol" 'my-erc-open-log)
(global-set-key "\C-cercs" 'my-erc-search-erg-logs)

(define-key erc-mode-map "\C-c\C-sl" 'my-erc-load-windows)
(define-key erc-mode-map "\C-c\C-st" 'my-erc-truncate-track)
;; (define-key erc-mode-map "\C-c\C-s\C-s\C-a" 'my-erc-edit-audience-erc)
;; (define-key erc-mode-map "\C-c\C-s\C-s\C-e" 'my-erc-edit-erc-auth)

(define-key erc-mode-map "\C-c\C-sS" 'my-erc-search-erg-logs)

(define-key erc-mode-map "\C-c\C-smr" 'my-erc-toggle-mute-monitoring)
(define-key erc-mode-map "\C-c\C-sms" 'my-erc-toggle-mute-reading)
(define-key erc-mode-map "\C-c\C-ss" 'my-erc-toggle-monitor-current-channel)
(define-key erc-mode-map "\C-c\C-sr" 'my-erc-toggle-read-current-channel)

(define-key erc-mode-map "\C-c\C-sas" 'my-erc-list-all-channels-being-monitored)
(define-key erc-mode-map "\C-c\C-sar" 'my-erc-list-all-channels-being-read)

(define-key erc-mode-map "\C-c\C-ses" 'my-erc-edit-channels-being-monitored)
(define-key erc-mode-map "\C-c\C-ser" 'my-erc-edit-channels-being-read)

(define-key erc-mode-map "\C-c\C-sv" 'my-erc-see-voice)


;; ;; (define-key erc-mode-map "" 'my-erc-list-all-channels-being-read)
;; ;; (define-key erc-mode-map "" 'my-erc-list-all-channels-being-monitored)

(defvar my-erc-dir "/var/lib/myfrdcsa/codebases/internal/audience/systems/irc/erc")
(defvar my-erc-mute-reading nil)
(defvar my-erc-mute-monitoring nil)

(defface erc-keyword-erc-face '((t (:foreground "Orchid")))
 "ERC face to highlight occurances of the word erc"
 :group 'erc-faces)

(defvar my-erc-page-message "%s: %s"
 "Format of message to display in dialog box")

(defvar my-erc-page-nick-alist nil
 "Alist of nicks and the last time they tried to trigger a
notification")

(defvar my-erc-page-timeout 30
 "Number of seconds that must elapse between notifications from
the same person.")

(defvar my-erc-monitor-channel-list 
 (make-hash-table :test 'equal))

(defvar my-erc-read-channel-list 
 (make-hash-table :test 'equal))

(defvar my-erc-channel-voice-list 
 (make-hash-table :test 'equal))

(defvar my-erc-monitor-list 
 (list "#posi" "#posi-core" "#posi-chat" "#posi-video" "#posi-bot" "#frdcsa" "#fsf"))

(defvar my-erc-read-list 
 (list "#posi" "#posi-core" "#posi-chat" "#posi-video" "#posi-bot" "#frdcsa" "#fsf" "#opencog" "#swig" "#opencyc" "#freeculture"))

(defvar my-erc-relay-to-audience t
 "Relay IRC messages to Audience through UEA")

(defun my-erc-edit-audience-erc ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsas/versions/myfrdcsa-1.0/codebases/releases/audience-0.2/audience-0.2/systems/irc/audience-erc.el"))

(defun my-erc-start-monitoring-channel (channel)
 ""
 (if (not (gethash channel my-erc-monitor-channel-list))
  (progn
   (puthash channel t my-erc-monitor-channel-list)
   (message 
    (concat "Monitoring " channel
     (if my-erc-mute-monitoring 
      ", however muting (monitoring) all channels is still enabled"
      ""))))))

(defun my-erc-stop-monitoring-channel (channel)
 ""
 (if (gethash channel my-erc-monitor-channel-list)
  (progn
   (remhash channel my-erc-monitor-channel-list)
   (message (concat "Stopped monitoring " channel)))))

(defun my-erc-start-reading-channel (channel)
 ""
 (if (not (gethash channel my-erc-read-channel-list))
  (progn
   (puthash channel t my-erc-read-channel-list)
   (message
    (concat "Reading " channel
     (if my-erc-mute-reading 
      ", however muting (reading) all channels is still enabled"
      ""))))))

(defun my-erc-stop-reading-channel (channel)
 ""
 (if (gethash channel my-erc-read-channel-list)
  (progn
   (remhash channel my-erc-read-channel-list)
   (message 
    (concat "Stopped reading " channel)))))

(defun my-erc-toggle-monitor-current-channel ()
 ""
 (interactive)
 (let ((channel (erc-default-target)))
  (if (gethash channel my-erc-monitor-channel-list)
   (my-erc-stop-monitoring-channel channel)
   (my-erc-start-monitoring-channel channel))))

(defun my-erc-toggle-read-current-channel ()
 ""
 (interactive)
 (let ((channel (erc-default-target)))
  (if (gethash channel my-erc-read-channel-list)
   (my-erc-stop-reading-channel channel)
   (my-erc-start-reading-channel channel))))

(defun my-erc-list-all-channels-being-read ()
 ""
 (interactive)
 (see my-erc-read-channel-list))

(defun my-erc-list-all-channels-being-monitored ()
 ""
 (interactive)
 (see my-erc-monitor-channel-list))

(defun my-erc-edit-channels-being-read ()
 ""
 (interactive)
 (kmax-edit-variable-value my-erc-read-channel-list))

(defun my-erc-edit-channels-being-monitored ()
 ""
 (interactive)
 (kmax-edit-variable-value my-erc-monitor-channel-list))

(mapcar
 (lambda (chan) "" (my-erc-start-monitoring-channel chan))
 my-erc-monitor-list
 )

(mapcar
 (lambda (chan) "" (my-erc-start-reading-channel chan))
 my-erc-read-list
 )

(defvar my-erc-monitor-channel-page-channel-alist nil
 "Alist of channels and the last time they tried to trigger a
notification")

(defvar my-erc-monitor-channel-page-timeout 120
 "Number of seconds that must elapse between notifications from
the same person.")

(defvar my-erc-voice-list nil)

(setq my-erc-voice-list 
 (list
  "ked_diphone"
  "rab_diphone"
  "don_diphone"
  "kal_diphone"
  "us1_mbrola"
  "us2_mbrola"
  "us3_mbrola"
  "cmu_us_awb_arctic_clunits"
  "cmu_us_bdl_arctic_clunits"
  "cmu_us_clb_arctic_clunits"
  "cmu_us_jmk_arctic_clunits"
  "cmu_us_rms_arctic_clunits"
  "cmu_us_slt_arctic_clunits"

					; "cstr_us_ked_timit_hts"
					; "nitech_us_slt_arctic_hts"
					; "cmu_us_kal_com_hts"
					; "nitech_us_bdl_arctic_hts"
					; "nitech_us_awb_arctic_hts"
					; "nitech_us_jmk_arctic_hts"
					; "nitech_us_clb_arctic_hts"
					; "nitech_us_rms_arctic_hts"
  ))

  ; "cmu_us_jmk_arctic_clunits"
  ; "cmu_us_bdl_arctic_clunits"
  ; "cmu_us_slt_arctic_clunits"
  ; "cmu_us_awb_arctic_clunits"
  ; "cmu_us_clb_arctic_clunits"
  ; "cmu_us_rms_arctic_clunits"

; (clrhash my-erc-channel-voice-list)

(defun my-erc-toggle-mute-reading ()
 ""
 (interactive)
 (if my-erc-mute-reading
  (message "Unmuting (reading) all channels")
  (message "Muting (reading) all channels"))
 (setq my-erc-mute-reading (not my-erc-mute-reading)))

(defun my-erc-toggle-mute-monitoring ()
 ""
 (interactive)
 (if my-erc-mute-monitoring
  (message "Unmuting (monitoring) all channels")
  (message "Muting (monitoring) all channels"))
 (setq my-erc-mute-monitoring (not my-erc-mute-monitoring)))

(defun my-erc-page-popup-notification (nick)
 (interactive)
 (when window-system
  ;; must set default directory, otherwise start-process is unhappy
  ;; when this is something remote or nonexistent
  (let ((default-directory "~/"))
   ;; 8640000 milliseconds = 1 day
   (start-process "page-me" nil "notify-send"
    "-u" "normal" "-t" "8640000" "ERC"
    (format my-erc-page-message (erc-default-target) nick))
   (start-process "play-sound" nil "/usr/bin/play"
    "/home/andrewdo/.emacs.d/erc/decide1.wav")
   )))

(defun my-erc-page-allowed (nick &optional delay)
 "Return non-nil if a notification should be made for NICK.
If DELAY is specified, it will be the minimum time in seconds
that can occur between two notifications.  The default is
'my-erc-page-timeout'."
 (unless delay (setq delay my-erc-page-timeout))
 (let ((cur-time (time-to-seconds (current-time)))
       (cur-assoc (assoc nick my-erc-page-nick-alist))
       (last-time))
  (if cur-assoc
   (progn
    (setq last-time (cdr cur-assoc))
    (setcdr cur-assoc cur-time)
    (> (abs (- cur-time last-time)) delay))
   (push (cons nick cur-time) my-erc-page-nick-alist)
   t)))

(defun my-erc-page-me (match-type nick message)
 "Notify the current user when someone sends a message that
matches a regexp in 'erc-keywords'."
 (interactive)
					; (message message)
					; (sit-for 3)
 (when (and (eq match-type 'keyword)
	;; I don't want to see anything from the erc server
	(null (string-match "\\`\\([sS]erver\\|localhost\\)" nick))
	;; or bots
	(null (string-match "\\(bot\\|serv\\)!" nick))
	;; or from those who abuse the system
	(my-erc-page-allowed nick))
  (my-erc-page-popup-notification nick)))

(add-hook 'erc-text-matched-hook 'my-erc-page-me)

(defun my-erc-page-me-PRIVMSG (proc parsed)
 (let ((nick (car (erc-parse-user (erc-response.sender parsed))))
       (target (car (erc-response.command-args parsed)))
       (msg (erc-response.contents parsed)))
  (when (and (erc-current-nick-p target)
	 (not (erc-is-message-ctcp-and-not-action-p msg))
	 (my-erc-page-allowed nick))
   (my-erc-page-popup-notification nick)
   nil)))
(add-hook 'erc-server-PRIVMSG-functions 'my-erc-page-me-PRIVMSG)


(add-hook 'erc-insert-modify-hook 'my-erc-match-message)
					; (remove-hook 'erc-insert-modify-hook 'my-erc-match-message)

(defun my-erc-monitor-channel-page-allowed (channel &optional delay)
 "Return non-nil if a notification should be made for channel.
If DELAY is specified, it will be the minimum time in seconds
that can occur between two notifications.  The default is
'my-erc-monitor-channel-page-timeout'."
 (unless delay (setq delay my-erc-monitor-channel-page-timeout))
 (let ((cur-time (time-to-seconds (current-time)))
       (cur-assoc (assoc channel my-erc-monitor-channel-page-channel-alist))
       (last-time))
  (if cur-assoc
   (progn
    (setq last-time (cdr cur-assoc))
    (setcdr cur-assoc cur-time)
    (> (abs (- cur-time last-time)) delay))
   (push (cons channel cur-time) my-erc-monitor-channel-page-channel-alist)
   t)))

(defun my-erc-match-message ()
 (interactive)
 (goto-char (point-min))
 (let* (
	(channel (erc-default-target))
	(contents (buffer-substring-no-properties (point-min) (point-max)))
	(vector (erc-get-parsed-vector (point-min)))
	(nickuserhost (erc-get-parsed-vector-nick vector))
	(nickname (and nickuserhost
		   (nth 0 (erc-parse-user nickuserhost))))
	(old-pt (point))
	(nick-beg (and nickname
		   (re-search-forward (regexp-quote nickname)
		    (point-max) t)
		   (match-beginning 0)))
	(nick-end (when nick-beg
		   (match-end 0)))
	(message (buffer-substring-no-properties (if (and nick-end
						      (<= (+ 2 nick-end) (point-max)))
						  (+ 2 nick-end)
						  (point-min))
		  (point-max)))
	)

  ;; go ahead and if we are supposed to be sending events from this
  ;; channel, send one to Audience
  (if (and
       uea-connected
       my-erc-relay-to-audience
       )
   (uea-send-contents message "Audience" (concat "$VAR1 = {Nickname => \"" (uea-xmlify-message nickname) "\", Channel => \"" (uea-xmlify-message channel) "\"};"))
   )

  (if (and
       (gethash channel my-erc-monitor-channel-list)
       (not my-erc-mute-monitoring)
       )
   (progn
    (when (and
	   window-system
	   (my-erc-monitor-channel-page-allowed channel))
     ;; must set default directory, otherwise start-process is unhappy
     ;; when this is something remote or nonexistent
     (let ((default-directory "~/"))
      ;; 8640000 milliseconds = 1 day
      (start-process "page-me" nil "notify-send"
       "-u" "normal" "-t" "8640000" "ERC"
       (concat "Activity in " channel))))
    (if (my-erc-system-message-p contents)
     (my-erc-play-sound-action)
     (my-erc-play-sound-message))
    )
   )
  (if (and
       (gethash channel my-erc-read-channel-list)
       (not my-erc-mute-reading)
       )
   (if (not (my-erc-system-message-p contents))
    (progn
     (my-erc-read-message channel nickname message)
					; (message message)
     )
    )
   )
  )
 )

(defun my-erc-system-message-p (contents)
 ""
 (or
  (not 
   (not 
    (string-match
     "\\(has[\s\n]+joined[\n\s]+channel\\|is[\s\n]+now[\s\n]+known[\s\n]+as\\|has[\s\n]+quit\\|has[\s\n]+left[\s\n]+channel\\)"
     contents)))
  (not 
   (not 
    (string-match
     "^\\*\\*\\*"
     contents)))))

(defun my-erc-play-sound-action ()
 ""
 (start-process "play-sound-action" nil "/usr/bin/play"
  (concat my-erc-dir "/beep.wav")))

(defun my-erc-play-sound-message ()
 ""
 (start-process "play-sound-action" nil "/usr/bin/play"
  (concat my-erc-dir "/ding.wav")))

(defun my-erc-read-message (channel nickname message)
 ""
 (interactive)
 (my-festival-say-string channel nickname message))

(setq festival-configuration 
 (shell-command-to-string "cat /etc/clear/fest.conf"))

; (my-festival-say-string "#emacs" "tom" "hello")
; (festival-say-string "hello")

(defun my-festival-say-string (channel nickname string)
 "Send string to festival and have it said"
 (interactive "sSay: ")
 (festival-start-process)
 (process-send-string festival-process "(voice_kal_diphone)")
 (process-send-string festival-process festival-configuration)
 (string-match "^#\\(.*\\)$" channel)
 (process-send-string festival-process 
  (concat "(SayText " (format "%S" (concat (match-string 1 channel) " " nickname)) ")\n")) 
 (let ((voice (my-festival-get-voice-for-nick channel nickname)))
  (if (not (string= voice ""))
   (process-send-string
    festival-process
    (concat "(voice_" 
     voice ")")))
  )
 (process-send-string festival-process festival-configuration)
 (process-send-string festival-process 
  (concat "(SayText " (format "%S" string) ")\n")))

; (process-send-string festival-process "(Parameter.set 'Duration_Stretch 0.4)")
; (hash-table-count my-erc-channel-voice-list)
; (gethash "aadis" (gethash "#emacs" my-erc-channel-voice-list))
; (my-erc-get-new-voice (gethash "#emacs" my-erc-channel-voice-list))
; (hash-table-count (gethash "#emacs" my-erc-channel-voice-list))
; (puthash "technomancy" (nth 7 my-erc-voice-list) (gethash "#emacs" my-erc-channel-voice-list))
; (puthash "mib_suic9j" (nth 8 my-erc-voice-list) (gethash "#posi-bot" my-erc-channel-voice-list))
; (gethash "mib_suic9j" (gethash "#posi-bot" my-erc-channel-voice-list))

(defun my-festival-get-voice-for-nick (channel nickname)
 ;; okay, retrieve the variable for the particular channel
 (if (not (gethash channel my-erc-channel-voice-list))
  (puthash channel (make-hash-table :test 'equal) my-erc-channel-voice-list)
  )
 (let* ((channelhash (gethash channel my-erc-channel-voice-list)))
  (if (not (gethash nickname channelhash))
   (puthash nickname (my-erc-get-new-voice channelhash) channelhash)
   )
  (gethash nickname channelhash)
  )
 )

(defun my-erc-get-new-voice (hash)
 (nth (- (min (+ (hash-table-count hash) 1) (length my-erc-voice-list)) 1) my-erc-voice-list))

(defun my-erc-see-voice ()
 ""
 (interactive)
 (message (my-festival-get-voice-for-nick (erc-default-target) (thing-at-point 'symbol))))

(defun my-erc-pay-attention-to-channel (text)
 ""
 (let ((channel (erc-default-target)))
  (my-erc-start-monitoring-channel channel)
  (my-erc-start-reading-channel channel)))

(defun my-erc-fix-windows ()
 ""
 (interactive)
 (delete-other-windows)
 (split-window-vertically)
 (split-window-horizontally)
 (other-window 1)
 (split-window-vertically)
 (other-window 2)
 (split-window-horizontally)
 (other-window -3))

(defun my-erc-fix-windows-orig ()
 ""
 (interactive)
 (delete-other-windows)
 (split-window-vertically)
 (split-window-horizontally)
 (other-window 2)
 (split-window-horizontally)
 (other-window -2))


(defun my-erc-select-windows (instance)
 ""
 (if (= instance 1)
  (progn
   (interactive)
   (switch-to-buffer "##prolog")
   (my-erc-normalize-chat-buffer)
   (other-window 1)
   (switch-to-buffer "#chiglug")
   (my-erc-normalize-chat-buffer)
   (other-window 1)
   (switch-to-buffer "#shinycms")
   (my-erc-normalize-chat-buffer)
   (other-window 1)
   ;; (switch-to-buffer "##narrative-ai")
   (switch-to-buffer "#ai")
   (my-erc-normalize-chat-buffer)
   (other-window 1)
   (switch-to-buffer "willthechill")
   (split-window-vertically)
   (other-window 1)
   (if (get-buffer "jbalint")
    (if (or (get-buffer "dmiles") (get-buffer "dmiles_afk") (get-buffer "logicmoo"))
     (progn (switch-to-buffer (get-buffer "jbalint"))
      (split-window-below)
      (switch-to-buffer (or (get-buffer "dmiles") (get-buffer "dmiles_afk") (get-buffer "logicmoo")))
      (my-erc-normalize-chat-buffer)
      (other-window 1)
      (my-erc-normalize-chat-buffer))
     (progn (switch-to-buffer (get-buffer "jbalint")) (my-erc-normalize-chat-buffer)))
    (if (or (get-buffer "dmiles") (get-buffer "dmiles_afk") (get-buffer "logicmoo"))
     (progn (switch-to-buffer (or (get-buffer "dmiles") (get-buffer "dmiles_afk") (get-buffer "logicmoo"))) (my-erc-normalize-chat-buffer))
     (shell))))
  (if (= instance 2)
   (progn
    (interactive)
    (switch-to-buffer "#opencyc")
    (my-erc-normalize-chat-buffer)
    (other-window 1)
    (switch-to-buffer "#logicmoo")
    (my-erc-normalize-chat-buffer)
    (other-window 1)
    (switch-to-buffer "##nlp")
    (my-erc-normalize-chat-buffer)
    (other-window 1)
    (switch-to-buffer "#intfiction")
    (my-erc-normalize-chat-buffer)))))

(defun my-erc-select-windows-orig (instance)
 ""
 (if (= instance 1)
  (progn
   (interactive)
   (switch-to-buffer "##prolog")
   (my-erc-normalize-chat-buffer)
   (other-window 1)
   (switch-to-buffer "#chiglug")
   (my-erc-normalize-chat-buffer)
   (other-window 1)
   ;; (switch-to-buffer "#shinycms")
   ;; (switch-to-buffer "##narrative-ai")
   (switch-to-buffer "#ai")
   (my-erc-normalize-chat-buffer)
   (other-window 1)
   (if (get-buffer "jbalint")
    (if (or (get-buffer "dmiles") (get-buffer "dmiles_afk") (get-buffer "logicmoo"))
     (progn (switch-to-buffer (get-buffer "jbalint"))
      (split-window-below)
      (switch-to-buffer (or (get-buffer "dmiles") (get-buffer "dmiles_afk") (get-buffer "logicmoo")))
      (my-erc-normalize-chat-buffer)
      (other-window 1)
      (my-erc-normalize-chat-buffer))
     (progn (switch-to-buffer (get-buffer "jbalint")) (my-erc-normalize-chat-buffer)))
    (if (or (get-buffer "dmiles") (get-buffer "dmiles_afk"))
     (progn (switch-to-buffer (or (get-buffer "dmiles") (get-buffer "dmiles_afk") (get-buffer "logicmoo"))) (my-erc-normalize-chat-buffer))
     (shell))))
  (if (= instance 2)
   (progn
    (interactive)
    (switch-to-buffer "#opencyc")
    (my-erc-normalize-chat-buffer)
    (other-window 1)
    (switch-to-buffer "#logicmoo")
    (my-erc-normalize-chat-buffer)
    (other-window 1)
    (switch-to-buffer "##nlp")
    (my-erc-normalize-chat-buffer)
    (other-window 1)
    (switch-to-buffer "#intfiction")
    (my-erc-normalize-chat-buffer))
   )
  ))

(defun my-erc-normalize-chat-buffer ()
 ""
 (end-of-buffer)
 (recenter-top-bottom '(4)))

(defun my-erc-load-windows (&optional arg)
 ""
 (interactive "P")
 (if arg
  (my-erc-truncate-track))
 (my-erc-fix-windows)
 (my-erc-select-windows audience-erc-instance)
 (kmax-map-end-of-buffer-and-recenter-top-bottom-over-all-visible-buffers nil))

(defun my-erc-truncate-track ()
 ""
 (interactive)
 (let ((my-current-buffer (current-buffer)))
  (dotimes (tmp 100) (erc-track-switch-buffer 0))
  (switch-to-buffer my-current-buffer)))

(defun my-erc-edit-erc-auth ()
 ""
 (interactive)
 (ffap (frdcsa-el-concat-dir (list homedir ".emacs.d" ".erc-auth.el"))))

(defvar my-erc-log-dir (frdcsa-el-concat-dir (list homedir ".erc/logs")))

(defun my-erc-search-erg-logs ()
 ""
 (interactive)
 (let ((search (read-from-minibuffer "Search?: ")))
  (kmax-search-files
   search
   (kmax-find-name-dired my-erc-log-dir ".txt")
   "*Audience-ERC Search*")))

(defun my-erc-open-log ()
 ""
 (interactive)
 (end-of-line)
 (let ((end-of-line-pos (point)))
  (beginning-of-line)
  (set-mark (point))
  (re-search-forward ".txt:")
  (backward-char)
  (let* ((filename (buffer-substring-no-properties (mark) (point)))
	 (text (progn
		(forward-char)
		(kmax-remove-bordering-whitespace-on-each-line
		 (buffer-substring-no-properties (point) end-of-line-pos)))))
   (beginning-of-line)
   (ffap filename)
   (see text 0.0)
   (beginning-of-buffer)
   (re-search-forward text)
   (beginning-of-line))))

(defun my-erc-closed-status ()
 ""
 (interactive)
 (cond ((and (erc-server-process-alive)
	 (not erc-server-connected))
	":connecting")
  ((erc-server-process-alive)
   ":alive")
  (t
   ":closed")))

(defun my-erc-closed-p ()
 ""
 (interactive)
 (string= (my-erc-closed-status) ":closed"))

;; FIXME: integrate with the manager system, in order to alert the
;; user as needed:
;; (see manager-send-message manager-outgoing-message-queue manager-start-logging manager-update)

;; Note: be advised it will try to use uea, which currently isn't
;; connected on every emacs instance.

;; should be a function to restart erc


;; (defun my-erc-watch-dog ()
;;  ""
;;  (interactive)
;;  (periodically
;;   (if (my-erc-closed-p)
;;    (message))))

(add-hook 'erc-send-completed-hook 'my-erc-pay-attention-to-channel)
