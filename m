From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 May 2010 21:40:12 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20100511214012.23137.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-05-11 21:40:12

Modified files:
	tools          : lvcreate.c 

Log message:
	If we are checking if '--nosync' was called with the mirror argument,
	then let's also check if '--mirrorlog' was called with the mirror
	argument.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.221&r2=1.222

--- LVM2/tools/lvcreate.c	2010/04/29 01:38:14	1.221
+++ LVM2/tools/lvcreate.c	2010/05/11 21:40:11	1.222
@@ -394,6 +394,11 @@
 			return 0;
 		}
 
+		if (arg_count(cmd, mirrorlog_ARG)) {
+			log_error("--mirrorlog is only available with mirrors");
+			return 0;
+		}
+
 		if (arg_count(cmd, nosync_ARG)) {
 			log_error("--nosync is only available with mirrors");
 			return 0;


