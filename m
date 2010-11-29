From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Nov 2010 11:14:33 -0000
Subject: LVM2/tools lvmcmdline.c
Message-ID: <20101129111433.13650.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-29 11:14:33

Modified files:
	tools          : lvmcmdline.c 

Log message:
	Remove dead assignment in lvm2_main
	
	'alias' is not read again in this code path.
	Also 'alias' is already equal to 0 in this place.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133

--- LVM2/tools/lvmcmdline.c	2010/11/24 09:53:31	1.132
+++ LVM2/tools/lvmcmdline.c	2010/11/29 11:14:33	1.133
@@ -1442,7 +1442,6 @@
 		if (!alias) {
 			argv++;
 			argc--;
-			alias = 0;
 		}
 		if (!argc) {
 			log_error("Falling back to LVM1 tools, but no "


