From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Aug 2011 14:54:48 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20110804145448.20398.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-04 14:54:48

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Add 'empty' command
	
	Using empty command ';' here makes the code look nicer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146

--- LVM2/tools/lvmcmdline.c	2011/08/04 14:11:28	1.145
+++ LVM2/tools/lvmcmdline.c	2011/08/04 14:54:48	1.146
@@ -275,6 +275,7 @@
 			return 0;
 		} else if (i == 7) {
 			/* v is already in sectors */
+			;
 		} else if (i == 6) {
 			/* bytes */
 			v_tmp = (uint64_t) v;


