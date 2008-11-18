From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Nov 2008 10:13:24 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20081118101324.3901.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-11-18 10:13:23

Modified files:
	tools          : lvmcmdline.c 

Log message:
	fix missing const char*

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/tools/lvmcmdline.c	2008/11/12 09:53:33	1.74
+++ LVM2/tools/lvmcmdline.c	2008/11/18 10:13:23	1.75
@@ -1218,7 +1218,7 @@
 
 int lvm2_main(int argc, char **argv, unsigned is_static)
 {
-	char *base;
+	const char *base;
 	int ret, alias = 0;
 	struct cmd_context *cmd;
 


