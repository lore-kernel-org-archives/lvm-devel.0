From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jul 2009 02:16:06 -0000
Subject: LVM2 lib/metadata/metadata.c tools/vgsplit.c
Message-ID: <20090714021606.7249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-14 02:16:06

Modified files:
	lib/metadata   : metadata.c 
	tools          : vgsplit.c 

Log message:
	Remove READ_REQUIRE_RESIZEABLE flag from vgsplit.
	
	Remove READ_REQUIRE_RESIZEABLE flag from vgsplit similar to the removal from
	vgextend.  Move the check inside the functions that actually move pvs from
	one vg structure to another.  Should be no functional change.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	Acked-by: Alasdair G Kergon <agk@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.248&r2=1.249
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/lib/metadata/metadata.c	2009/07/14 02:15:21	1.248
+++ LVM2/lib/metadata/metadata.c	2009/07/14 02:16:05	1.249
@@ -70,6 +70,8 @@
 static vg_t *_vg_make_handle(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     uint32_t failure);
+static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
+				    uint32_t status);
 
 unsigned long set_pe_align(struct physical_volume *pv, unsigned long data_alignment)
 {
@@ -287,6 +289,10 @@
 		return 0;
 	}
 
+	if (_vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
+	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
+		return 0;
+
 	dm_list_move(&vg_to->pvs, &pvl->list);
 
 	vg_from->pv_count--;
@@ -319,6 +325,10 @@
 		return 0;
 	}
 
+	if (_vg_bad_status_bits(vg_from, RESIZEABLE_VG) ||
+	    _vg_bad_status_bits(vg_to, RESIZEABLE_VG))
+		return 0;
+
 	dm_list_iterate_items(lvseg, &lvl->lv->segments) {
 		if (lvseg->log_lv)
 			if (!move_pvs_used_by_lv(vg_from, vg_to,
--- LVM2/tools/vgsplit.c	2009/07/14 02:15:21	1.84
+++ LVM2/tools/vgsplit.c	2009/07/14 02:16:05	1.85
@@ -248,8 +248,7 @@
 
 	log_verbose("Checking for volume group \"%s\"", vg_name_from);
 
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL,
-				     READ_REQUIRE_RESIZEABLE);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
 	if (vg_read_error(vg_from)) {
 		vg_release(vg_from);
 		return ECMD_FAILED;
@@ -283,8 +282,7 @@
 	if (vg_read_error(vg_to) == FAILED_EXIST) {
 		existing_vg = 1;
 		vg_release(vg_to);
-		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
-					   READ_REQUIRE_RESIZEABLE);
+		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
 
 		if (vg_read_error(vg_to)) {
 			vg_release(vg_to);


