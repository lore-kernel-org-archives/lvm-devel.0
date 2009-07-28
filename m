From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2009 20:41:43 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090728204143.629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-28 20:41:42

Modified files:
	lib/metadata   : metadata.c 

Log message:
	\n

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.272&r2=1.273

--- LVM2/lib/metadata/metadata.c	2009/07/28 15:14:56	1.272
+++ LVM2/lib/metadata/metadata.c	2009/07/28 20:41:41	1.273
@@ -3046,7 +3046,7 @@
 int vg_check_write_mode(vg_t *vg)
 {
 	if (vg->open_mode != 'w') {
-		log_errno(EPERM, "Attempt to modify a read-only VG\n");
+		log_errno(EPERM, "Attempt to modify a read-only VG");
 		return 0;
 	}
 	return 1;


