From: pcaulfield@sourceware.org <pcaulfield@sourceware.org>
Date: 11 Dec 2006 14:06:27 -0000
Subject: LVM2 ./WHATS_NEW man/clvmd.8
Message-ID: <20061211140627.31883.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	pcaulfield at sourceware.org	2006-12-11 14:06:26

Modified files:
	.              : WHATS_NEW 
	man            : clvmd.8 

Log message:
	Add manpage reference for clvmd -T that got missed out when I
	checked the code in (sorry).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.517&r2=1.518
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/clvmd.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/WHATS_NEW	2006/12/11 14:00:26	1.517
+++ LVM2/WHATS_NEW	2006/12/11 14:06:25	1.518
@@ -1,5 +1,6 @@
 Version 2.02.17 -
 ===================================
+  Add manpage entry for clvmd -T
   Fix gulm operation of clvmd, including a hang when doing lvchange -aey
   Fix hang in clvmd if a pre-command failed.
 
--- LVM2/man/clvmd.8	2006/10/04 08:28:17	1.3
+++ LVM2/man/clvmd.8	2006/12/11 14:06:25	1.4
@@ -6,6 +6,7 @@
 [\-d] [\-h]
 [\-R]
 [\-t <timeout>]
+[\-T <start timeout>]
 [\-V]
 .SH DESCRIPTION
 clvmd is the daemon that distributes LVM metadata updates around a cluster.
@@ -23,6 +24,23 @@
 may need to increase this on systems with very large disk farms. 
 The default is 30 seconds.
 .TP
+.I \-T <start timeout>
+Specifies the timeout for clvmd daemon startup. If the daemon does not report 
+that it has started up within this time then the parent command will exit with 
+status of 5. This does NOT mean that clvmd has not started! What it means is 
+that the startup of clvmd has been delayed for some reason; the most likely 
+cause of this is an inquorate cluster though it could be due to locking 
+latencies on a cluster with large numbers of logical volumes. If you get the 
+return code of 5 it is usually not necessary to restart clvmd - it will start
+as soon as that blockage has cleared. This flag is to allow startup scripts
+to exit in a timely fashion even if the cluster is stalled for some reason.
+<br>
+The default is 0 (no timeout) and the value is in seconds. Don't set this too
+small or you will experience spurious errors. 10 or 20 seconds might be
+sensible.
+<br>
+This timeout will be ignored if you start clvmd with the -d switch.
+.TP
 .I \-R
 Tells all the running clvmd in the cluster to reload their device cache and
 re-read the lvm configuration file. This command should be run whenever the


