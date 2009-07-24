From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Jul 2009 15:12:50 -0000
Subject: LVM2/liblvm lvm_vg.c
Message-ID: <20090724151250.17299.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-24 15:12:50

Modified files:
	liblvm         : lvm_vg.c 

Log message:
	Update lvm_vg_extend() to obtain VG_ORPHAN.
	
	vg_extend() no longer obtains VG_OPHAN so we must do so in liblvm function.
	We still have the race in liblvm but we will address this problem later.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/liblvm/lvm_vg.c	2009/07/24 12:48:21	1.8
+++ LVM2/liblvm/lvm_vg.c	2009/07/24 15:12:50	1.9
@@ -40,11 +40,23 @@
 int lvm_vg_extend(vg_t *vg, const char *device)
 {
 	if (vg_read_error(vg))
-		goto_bad;
+		return 0;
 
-	return vg_extend(vg, 1, (char **) &device);
-bad:
-	return 0;
+	if (!lock_vol(vg->cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
+	if (!vg_extend(vg, 1, (char **) &device)) {
+		unlock_vg(vg->cmd, VG_ORPHANS);
+		return 0;
+	}
+	/*
+	 * FIXME: Either commit to disk, or keep holding VG_ORPHANS and
+	 * release in lvm_vg_close().
+	 */
+	unlock_vg(vg->cmd, VG_ORPHANS);
+	return 1;
 }
 
 int lvm_vg_set_extent_size(vg_t *vg, uint32_t new_size)


