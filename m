From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Apr 2007 17:14:58 -0000
Subject: LVM2 lib/device/dev-cache.c man/lvm.conf.5
Message-ID: <20070426171458.5977.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-04-26 18:14:57

Modified files:
	lib/device     : dev-cache.c 
	man            : lvm.conf.5 

Log message:
	add preferred_names to man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/lib/device/dev-cache.c	2007/04/26 16:44:58	1.46
+++ LVM2/lib/device/dev-cache.c	2007/04/26 17:14:57	1.47
@@ -155,6 +155,9 @@
 	char *s0, *s1;
 	struct stat stat0, stat1;
 
+	/*
+	 * FIXME Better to compare patterns one-at-a-time against all names.
+	 */
 	if (_cache.preferred_names_matcher) {
 		m0 = matcher_run(_cache.preferred_names_matcher, path0);
 		m1 = matcher_run(_cache.preferred_names_matcher, path1);
--- LVM2/man/lvm.conf.5	2007/02/28 18:27:13	1.18
+++ LVM2/man/lvm.conf.5	2007/04/26 17:14:57	1.19
@@ -81,6 +81,11 @@
 Devices in directories outside this hierarchy will be ignored.
 Defaults to "/dev".
 .IP
+\fBpreferred_names\fP \(em List of patterns compared in turn against
+all the pathnames referencing the same device in in the scanned directories.
+The pathname that matches the earliest pattern in the list is the
+one used in any output.
+.IP
 \fBfilter\fP \(em List of patterns to apply to devices found by a scan.
 Patterns are regular expressions delimited by any character and preceded
 by \fBa\fP (for accept) or \fBr\fP (for reject).  The list is traversed


