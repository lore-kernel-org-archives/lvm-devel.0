From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 22 Jan 2010 21:48:17 -0000
Subject: LVM2/man cmirrord.8.in
Message-ID: <20100122214817.29882.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-22 21:48:17

Modified files:
	man            : cmirrord.8.in 

Log message:
	a little more information for the cmirrord man page

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/cmirrord.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/man/cmirrord.8.in	2010/01/20 15:17:25	1.2
+++ LVM2/man/cmirrord.8.in	2010/01/22 21:48:17	1.3
@@ -7,7 +7,24 @@
 
 .SH DESCRIPTION
 cmirrord is the daemon that tracks mirror log information in a cluster.
-Cluster mirrors are not possible without this daemon running.
+It is specific to device-mapper based mirrors (and by extension, LVM
+cluster mirrors).  Cluster mirrors are not possible without this daemon
+running.
+
+This daemon relies on the cluster infrastructure provided by the
+Cluster MANager (CMAN), which must be set up and running in order for
+cmirrord to function.  (The cluster infrastructure is also required for
+clvmd.)
+
+Output is logged via syslog.  The USR1 signal can be issued to cmirrord
+to gather current status information for debugging purposes.
+
+Once started, cmirrord will run until it is shutdown via INT signal.  If
+there are still active cluster mirrors, however, the signal will be
+ignored.  Active cluster mirrors should be shutdown before stopping the
+cluster mirror log daemon.
 
 .SH SEE ALSO
+.BR lvm (8)
 .BR clvmd (8)
+.BR cluster.conf (5)
\ No newline at end of file


