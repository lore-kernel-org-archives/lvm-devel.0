From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Nov 2008 09:49:06 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20081112094906.9121.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-11-12 09:49:06

Modified files:
	tools          : lvmcmdline.c 

Log message:
	minor compiler warning fix for function declaration prototype

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/tools/lvmcmdline.c	2008/11/03 22:14:30	1.72
+++ LVM2/tools/lvmcmdline.c	2008/11/12 09:49:06	1.73
@@ -1210,7 +1210,7 @@
 	log_sys_error("execvp", path);
 }
 
-static void _nonroot_warning()
+static void _nonroot_warning(void)
 {
 	if (getuid() || geteuid())
 		log_warn("WARNING: Running as a non-root user. Functionality may be unavailable.");


