From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 6 Jan 2010 19:08:58 -0000
Subject: LVM2 man/lvchange.8.in man/vgchange.8.in tools ...
Message-ID: <20100106190858.23346.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-06 19:08:58

Modified files:
	man            : lvchange.8.in vgchange.8.in 
	tools          : lvchange.c vgchange.c 

Log message:
	. update documentation for --poll in the vgchange and lvchange man pages
	. add high-level --poll FIXMEs to vgchange.c and lvchange.c

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgchange.8.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/man/lvchange.8.in	2010/01/05 20:56:51	1.5
+++ LVM2/man/lvchange.8.in	2010/01/06 19:08:58	1.6
@@ -64,12 +64,12 @@
 set in \fBlvm.conf\fP.
 .TP
 .I \-\-poll y|n
-Controls whether or not a logical volume's progress is polled.  It may
-not be appropriate to immediately poll the progress of a logical
-volume's transformation when it is activated (for example, when merging
-a snapshot into the root FS).  The progress polling of an incomplete
-pvmove or lvconvert can be deferred using \fB--poll n\fP and restarted
-using \fB--poll y\fP.
+Without polling a logical volume's backgrounded transformation process
+will never complete.  If there is an incomplete pvmove or lvconvert (for
+example, on rebooting after a crash), use \fB--poll y\fP to restart the
+process from its last checkpoint.  However, it may not be appropriate to
+immediately poll a logical volume when it is activated, use \fB--poll
+n\fP to defer and then \fB--poll y\fP to restart the process.
 .TP
 .I \-\-noudevsync
 Disable udev synchronisation. The
--- LVM2/man/vgchange.8.in	2010/01/05 20:56:51	1.6
+++ LVM2/man/vgchange.8.in	2010/01/06 19:08:58	1.7
@@ -89,12 +89,12 @@
 .BR lvm.conf (5).
 .TP
 .BR \-\-poll " " { y | n }
-Controls whether or not a logical volume's progress is polled.  It may
-not be appropriate to immediately poll the progress of a logical
-volume's transformation when it is activated (for example, when merging
-a snapshot into the root FS).  The progress polling of an incomplete
-pvmove or lvconvert can be deferred using \fB--poll n\fP and restarted
-using \fB--poll y\fP.
+Without polling a logical volume's backgrounded transformation process
+will never complete.  If there is an incomplete pvmove or lvconvert (for
+example, on rebooting after a crash), use \fB--poll y\fP to restart the
+process from its last checkpoint.  However, it may not be appropriate to
+immediately poll a logical volume when it is activated, use \fB--poll
+n\fP to defer and then \fB--poll y\fP to restart the process.
 .TP
 .BR \-\-noudevsync
 Disable udev synchronisation. The
--- LVM2/tools/lvchange.c	2010/01/05 21:07:31	1.115
+++ LVM2/tools/lvchange.c	2010/01/06 19:08:58	1.116
@@ -596,6 +596,13 @@
 					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
+	/*
+	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
+	 * If --poll is explicitly provided use it; otherwise polling
+	 * should only be started if the LV is not already active. So:
+	 * 1) change the activation code to say if the LV was actually activated
+	 * 2) make polling of an LV tightly coupled with LV activation
+	 */
 	init_background_polling(arg_int_value(cmd, poll_ARG,
 					      DEFAULT_BACKGROUND_POLLING));
 
--- LVM2/tools/vgchange.c	2010/01/05 21:08:34	1.94
+++ LVM2/tools/vgchange.c	2010/01/06 19:08:58	1.95
@@ -548,6 +548,13 @@
 					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
 					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
 
+	/*
+	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
+	 * If --poll is explicitly provided use it; otherwise polling
+	 * should only be started if the LV is not already active. So:
+	 * 1) change the activation code to say if the LV was actually activated
+	 * 2) make polling of an LV tightly coupled with LV activation
+	 */
 	init_background_polling(arg_int_value(cmd, poll_ARG,
 					      DEFAULT_BACKGROUND_POLLING));
 


