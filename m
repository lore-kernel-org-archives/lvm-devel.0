From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Sep 2009 00:29:13 -0000
Subject: LVM2/tools lvm2cmd.h
Message-ID: <20090926002913.1015.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-26 00:29:13

Modified files:
	tools          : lvm2cmd.h 

Log message:
	Fix log fn prototype.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/tools/lvm2cmd.h	2007/08/20 20:55:30	1.3
+++ LVM2/tools/lvm2cmd.h	2009/09/26 00:29:13	1.4
@@ -18,7 +18,8 @@
 
 #ifndef _LVM_LOG_H
 typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
-			       const char *message);
+                               int dm_errno, const char *message);
+
 #endif
 
 #define LVM2_LOG_SUPPRESS	0


