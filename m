From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:34 +0000 (UTC)
Subject: master - format_text: properly validate PV size for restore
Message-ID: <20150508131634.4DD1860759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05934d2538b76134fe4a5f4ddd7954ff32620b50
Commit:        05934d2538b76134fe4a5f4ddd7954ff32620b50
Parent:        2cea1c1bd9d432a7544713c49620e4cc2ab56ee6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 11:08:49 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:12:35 2015 +0200

format_text: properly validate PV size for restore

Use 64bit arithmentic for PV size calculation (Coverity).

Also remove sector shift for compared PV size, since all
values are already held in sectors.

This fixes validatio of PV size when restoring PV
from vg metadata backup file.
---
 WHATS_NEW                      |    1 +
 lib/format_text/format-text.c  |    6 +++---
 test/shell/pvcreate-restore.sh |   37 +++++++++++++++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3b22ec5..24f0c76 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Properly validate PV size for pvcreate --restorefile.
   Fix check if pvcreate wiped device (2.02.117).
   Fix storing of vgid when caching metadata (2.02.118).
   Fix recursive lvm-config man page. (2.02.119)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 759ad89..f38628c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1603,9 +1603,9 @@ static int _text_pv_initialise(const struct format_type *fmt,
 	if (rp->extent_count)
 		pv->pe_count = rp->extent_count;
 
-	if ((pv->pe_start + pv->pe_count * pv->pe_size - 1) > (pv->size << SECTOR_SHIFT)) {
+	if ((pv->pe_start + pv->pe_count * (uint64_t)pv->pe_size - 1) > pv->size) {
 		log_error("Physical extents end beyond end of device %s.",
-			   pv_dev_name(pv));
+			  pv_dev_name(pv));
 		return 0;
 	}
 
@@ -2172,7 +2172,7 @@ static int _text_pv_add_metadata_area(const struct format_type *fmt,
 		 * LABEL_SCAN_SIZE.
 		 */
 		pe_end = pv->pe_count ? (pv->pe_start +
-					 pv->pe_count * pv->pe_size - 1) << SECTOR_SHIFT
+					 pv->pe_count * (uint64_t)pv->pe_size - 1) << SECTOR_SHIFT
 				      : 0;
 
 		if (pe_start || pe_start_locked) {
diff --git a/test/shell/pvcreate-restore.sh b/test/shell/pvcreate-restore.sh
new file mode 100644
index 0000000..7331396
--- /dev/null
+++ b/test/shell/pvcreate-restore.sh
@@ -0,0 +1,37 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+aux prepare_vg 4
+
+lvcreate --type snapshot -s -L10 -n $lv1 $vg --virtualsize 2T
+lvcreate --type snapshot -s -L10 -n $lv2 $vg --virtualsize 4T
+lvcreate --type snapshot -s -L10 -n $lv3 $vg --virtualsize 4194300M
+
+aux extend_filter_LVMTEST
+
+vgcreate $vg1 "$DM_DEV_DIR/$vg/$lv2"
+
+vgcfgbackup -f vgback $vg1
+
+UUID=$(get pv_field "$DM_DEV_DIR/$vg/$lv2" uuid)
+pvremove -ff -y "$DM_DEV_DIR/$vg/$lv2"
+
+# too small to fit
+fail pvcreate --restorefile vgback --uuid $UUID "$DM_DEV_DIR/$vg/$lv1"
+
+# still does not fit
+fail pvcreate --restorefile vgback --uuid $UUID "$DM_DEV_DIR/$vg/$lv3"
+
+pvcreate --restorefile vgback --uuid $UUID "$DM_DEV_DIR/$vg/$lv2"
+
+vgremove -ff $vg


