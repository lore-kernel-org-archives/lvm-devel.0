From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2009 17:22:09 -0000
Subject: LVM2 VERSION_DM WHATS_NEW_DM
Message-ID: <20090728172209.14420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-28 17:22:08

Modified files:
	.              : VERSION_DM WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.288&r2=1.289

--- LVM2/VERSION_DM	2009/07/15 15:38:41	1.15
+++ LVM2/VERSION_DM	2009/07/28 17:22:07	1.16
@@ -1 +1 @@
-1.02.35-cvs (2009-07-15)
+1.02.35-cvs (2009-07-28)
--- LVM2/WHATS_NEW_DM	2009/07/15 15:38:41	1.288
+++ LVM2/WHATS_NEW_DM	2009/07/28 17:22:07	1.289
@@ -1,5 +1,7 @@
-Version 1.02.35 - 
+Version 1.02.35 - 28th July 2009
 ================================
+  Add LOG_LINE_WITH_ERRNO macro.
+  Use log_error macro consistently throughout in place of log_err.
 
 Version 1.02.34 - 15th July 2009
 ================================


