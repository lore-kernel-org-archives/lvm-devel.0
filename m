From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2010 19:26:37 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20101208192637.9189.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-08 19:26:36

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Cope better with an undefined target_percent operation in _percent_run.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1830&r2=1.1831
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.207&r2=1.208

--- LVM2/WHATS_NEW	2010/12/08 10:45:37	1.1830
+++ LVM2/WHATS_NEW	2010/12/08 19:26:35	1.1831
@@ -1,6 +1,7 @@
 Version 2.02.79 -
 ===================================
-  Fix write to released memory in vg_relase().  (2.02.78)
+  Cope better with an undefined target_percent operation in _percent_run.
+  Fix write to released memory in vg_release().  (2.02.78)
 
 Version 2.02.78 - 6th December 2010
 ===================================
--- LVM2/lib/activate/dev_manager.c	2010/11/30 22:28:06	1.207
+++ LVM2/lib/activate/dev_manager.c	2010/12/08 19:26:36	1.208
@@ -507,8 +507,10 @@
 				continue;
 		}
 
-		if (segtype->ops->target_percent &&
-		    !segtype->ops->target_percent(&dm->target_state,
+		if (!segtype->ops->target_percent)
+			continue;
+
+		if (!segtype->ops->target_percent(&dm->target_state,
 						  &percent, dm->mem,
 						  dm->cmd, seg, params,
 						  &total_numerator,


