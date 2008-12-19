From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Dec 2008 18:51:02 -0000
Subject: LVM2/tools lvm2cmdline.h
Message-ID: <20081219185102.15829.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-12-19 18:51:02

Modified files:
	tools          : lvm2cmdline.h 

Log message:
	lvm2cmdline.h:31: warning: declaration of `is_static' shadows a global declaration

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmdline.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/tools/lvm2cmdline.h	2008/12/18 05:27:18	1.7
+++ LVM2/tools/lvm2cmdline.h	2008/12/19 18:51:02	1.8
@@ -28,7 +28,7 @@
 
 int lvm2_main(int argc, char **argv);
 
-void *cmdlib_lvm2_init(unsigned is_static);
+void *cmdlib_lvm2_init(unsigned static_compile);
 void lvm_fin(struct cmd_context *cmd);
 
 struct cmd_context *init_lvm(void);


