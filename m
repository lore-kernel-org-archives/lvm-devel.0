From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Feb 2012 00:19:15 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120229001915.9690.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-29 00:19:15

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Fix a whitespace bug in the last checkin.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.492&r2=1.493

--- LVM2/lib/metadata/metadata.c	2012/02/29 00:18:27	1.492
+++ LVM2/lib/metadata/metadata.c	2012/02/29 00:19:14	1.493
@@ -2796,7 +2796,7 @@
 		return_NULL;
 
 	vg = fmt->orphan_vg;
-        dm_list_init(&vg->pvs);
+	dm_list_init(&vg->pvs);
 	vg->pv_count = 0;
 
 	baton.warnings = warnings;


