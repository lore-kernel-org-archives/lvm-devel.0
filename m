From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Sep 2011 09:25:52 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20110907092552.25686.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-07 09:25:51

Modified files:
	tools          : lvcreate.c 

Log message:
	Check if lp.origin exists
	
	Currently needed for _determine_snapshot_type().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.238&r2=1.239

--- LVM2/tools/lvcreate.c	2011/09/06 22:43:58	1.238
+++ LVM2/tools/lvcreate.c	2011/09/07 09:25:51	1.239
@@ -896,7 +896,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (lp.snapshot && !_determine_snapshot_type(vg, &lp)) {
+	if (lp.snapshot && lp.origin && !_determine_snapshot_type(vg, &lp)) {
 		r = ECMD_FAILED;
 		goto_out;
 	}


