From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:40:29 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20111110124029.6742.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:40:29

Modified files:
	tools          : lvcreate.c 

Log message:
	Thin move _read_activation_params check
	
	Since we finaly recognize thin creation only after
	_determine_snapshot_type() - move _read_activation_params()
	after it - so we can support  lvcreate -an thin snapshot.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.248&r2=1.249

--- LVM2/tools/lvcreate.c	2011/11/10 12:39:46	1.248
+++ LVM2/tools/lvcreate.c	2011/11/10 12:40:29	1.249
@@ -789,9 +789,6 @@
 		return 0;
 	}
 
-	if (!_read_activation_params(lp, cmd))
-		return_0;
-
 	/*
 	 * Allocation parameters
 	 */
@@ -993,6 +990,15 @@
 		goto_out;
 	}
 
+	/*
+	 * Check activation parameters to support inactive thin snapshot creation
+	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?
+	 */
+	if (!_read_activation_params(&lp, cmd)) {
+		r = ECMD_FAILED;
+		goto_out;
+	}
+
 	if (!_update_extents_params(vg, &lp, &lcp)) {
 		r = ECMD_FAILED;
 		goto_out;


