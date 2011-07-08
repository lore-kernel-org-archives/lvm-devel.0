From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 17:31:06 -0000
Subject: LVM2/lib/commands toolcontext.c
Message-ID: <20110708173106.23017.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 17:31:06

Modified files:
	lib/commands   : toolcontext.c 

Log message:
	missing ifdef when new fn unused

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/lib/commands/toolcontext.c	2011/07/08 16:49:04	1.125
+++ LVM2/lib/commands/toolcontext.c	2011/07/08 17:31:06	1.126
@@ -200,6 +200,7 @@
 	reset_lvm_errno(1);
 }
 
+#ifdef UDEV_SYNC_SUPPORT
 /*
  * Until the DM_UEVENT_GENERATED_FLAG was introduced in kernel patch 
  * 856a6f1dbd8940e72755af145ebcd806408ecedd
@@ -214,6 +215,7 @@
 	       (sscanf(vsn, "%u.%u.%u", &maj, &min, &patchlevel) == 3) &&
 	       (maj == 4 ? min >= 18 : maj > 4);
 }
+#endif
 
 static int _process_config(struct cmd_context *cmd)
 {


