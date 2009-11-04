From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Nov 2009 12:39:57 -0000
Subject: LVM2/tools lvchange.c
Message-ID: <20091104123957.16754.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-11-04 12:39:56

Modified files:
	tools          : lvchange.c 

Log message:
	minor code comment update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/tools/lvchange.c	2009/09/29 20:22:35	1.111
+++ LVM2/tools/lvchange.c	2009/11/04 12:39:56	1.112
@@ -610,7 +610,7 @@
 		docmds++;
 	}
 
-	/* read ahead sector change */
+	/* persistent device number change */
 	if (arg_count(cmd, persistent_ARG)) {
 		if (!archived && !archive(lv->vg)) {
 			stack;


