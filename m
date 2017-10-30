From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Oct 2017 09:39:41 -0400
Subject: master - validation: capture store of LV without segment
Message-ID: <201710301339.v9UDdfmE015265@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04244107732feb5274bc24efed428a0d4ddae8f6
Commit:        04244107732feb5274bc24efed428a0d4ddae8f6
Parent:        e9206fb93dcbc7c07ee7f6c4438f1dbd91c4d73a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 30 14:34:30 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 30 14:39:16 2017 +0100

validation: capture store of LV without segment

---
 WHATS_NEW                      |    1 +
 lib/metadata/merge.c           |    5 +++++
 test/shell/metadata-balance.sh |   15 ++++++++++++---
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e8e6bb0..0ee52ba 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Do not allow storing VG metadata with LV without any segment.
   Fix printed message when thin snapshot was already merged.
   Remove created spare LV when creation of thin-pool failed.
   Avoid reading ignored metadata when mda gets used again.
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 7de0c10..d5024cf 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -628,6 +628,11 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		inc_error_count;
 	}
 
+	if (!le) {
+		log_error("LV %s: has no segment.", lv->name);
+		inc_error_count;
+	}
+
 	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		seg = sl->seg;
 		seg_found = 0;
diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index fe94aed..1f22b24 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -189,8 +189,8 @@ done
 echo Test special situations, vgsplit, vgmerge, etc
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	vgcreate --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
-	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg2 "$dev4" "$dev5"
+	vgcreate -cy --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
+	vgcreate -cy --vgmetadatacopies $(( mdacp * 1 )) $vg2 "$dev4" "$dev5"
 	echo vgsplit/vgmerge preserves value of metadata copies
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg2 vg_mda_copies $(( mdacp * 1 ))
@@ -200,7 +200,16 @@ for mdacp in 1 2; do
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg1 vg_mda_count $(( mdacp * 5 ))
 	echo vgsplit into new vg sets proper value of vgmetadatacopies
-	vgsplit --vgmetadatacopies $(( mdacp * 2 )) $vg1 $vg2 "$dev1" "$dev2"
+#	echo y | pvchange -y --metadataignore n "$dev3" || true
+#	echo y | pvchange -y --metadataignore y "$dev4" || true
+#	echo y | pvchange -y --metadataignore n "$dev5" || true
+#	echo y | pvchange -y --metadataignore y "$dev1" || true
+#	echo y | pvchange -y --metadataignore y "$dev2" || true
+        pvs -o+pv_mda_size,pv_mda_count,pv_mda_used_count,pv_in_use
+        pvdisplay
+
+	#LVM_GDB=1
+        vgsplit --vgmetadatacopies $(( mdacp * 2 )) $vg1 $vg2 "$dev1" "$dev2"
 	check vg_field $vg2 vg_mda_copies $(( mdacp * 2 ))
 	echo vgchange fails if given both vgmetadatacopies and metadatacopies
 	not vgchange --vgmetadatacopies 5 --metadatacopies 7 $vg2


