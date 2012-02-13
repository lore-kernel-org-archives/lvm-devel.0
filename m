From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 12:07:51 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20120213120751.6383.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 12:07:51

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Handle all succefull values from open()

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.149&r2=1.150

--- LVM2/tools/lvmcmdline.c	2011/12/08 21:24:10	1.149
+++ LVM2/tools/lvmcmdline.c	2012/02/13 12:07:51	1.150
@@ -1149,7 +1149,7 @@
 
 	snprintf(buf, sizeof(buf), DEFAULT_PROC_DIR "/%u/cmdline", pid);
 	/* FIXME Use generic read code. */
-	if ((fd = open(buf, O_RDONLY)) > 0) {
+	if ((fd = open(buf, O_RDONLY)) >= 0) {
 		if ((n = read(fd, _proc_cmdline, sizeof(_proc_cmdline) - 1)) < 0) {
 			log_sys_error("read", buf);
 			n = 0;


