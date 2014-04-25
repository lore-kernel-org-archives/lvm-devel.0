From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 25 Apr 2014 21:26:15 +0000 (UTC)
Subject: master - vgsplit: Make RAID 4/5/6 fail cleanly when too few PV specified
Message-ID: <20140425212615.4246C61518@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c4234f825c93c9cd61409ade9039ba4033c8008
Commit:        3c4234f825c93c9cd61409ade9039ba4033c8008
Parent:        4dffb9fca9dba16bba0ec41ecc16ed42fe2dd4cf
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Apr 25 16:24:50 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Apr 25 16:24:50 2014 -0500

vgsplit: Make RAID 4/5/6 fail cleanly when too few PV specified

While the 'raid1/10' segment types were being handled inadvertently
by '_move_mirrors()', the parity RAIDs were not being properly checked
to ensure that the user had specified all necessary PVs when moving
them.  Thus, internal errors were being triggered when only part of
a RAID LV was moved to the new VG.  I've added a new function,
'_move_raid()', which properly checks over any affected RAID LVs and
ensures that all the necessary PVs are being moved.
---
 WHATS_NEW                       |    1 +
 test/shell/vgsplit-operation.sh |    6 ++--
 tools/vgsplit.c                 |   47 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index af9f6c3..3f879c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Make vgsplit fail cleanly when not all PVs are specified for RAID 4/5/6.
   Make vgsplit work on mirrors with logs that share PVs with images.
   Use devices/ignore_suspended_devices=0 by default if not defined in lvm.conf.
   Use proper libmem mempool for allocation of unknown segment name.
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 5dbff69..3a8a51a 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -238,9 +238,9 @@ COMM "vgsplit correctly splits RAID LV into $i VG ($j args)"
 
 		lvcreate -an -Zn -l 64 --type raid5 -i 2 -n $lv1 $vg1
 		if [ $j = PV ]; then
-#		  not vgsplit $vg1 $vg2 "$dev1"
-#		  not vgsplit $vg1 $vg2 "$dev2"
-#		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
+		  not vgsplit $vg1 $vg2 "$dev1"
+		  not vgsplit $vg1 $vg2 "$dev2"
+		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 9d26079..fb67919 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -66,6 +66,9 @@ static int _move_lvs(struct volume_group *vg_from, struct volume_group *vg_to)
 		if ((lv->status & SNAPSHOT))
 			continue;
 
+		if (lv_is_raid(lv))
+			continue;
+
 		if ((lv->status & MIRRORED))
 			continue;
 
@@ -184,6 +187,9 @@ static int _move_mirrors(struct volume_group *vg_from,
 	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
 		lv = dm_list_item(lvh, struct lv_list)->lv;
 
+		if (lv_is_raid(lv))
+			continue;
+
 		if (!(lv->status & MIRRORED))
 			continue;
 
@@ -226,6 +232,43 @@ static int _move_mirrors(struct volume_group *vg_from,
 	return 1;
 }
 
+static int _move_raid(struct volume_group *vg_from,
+		      struct volume_group *vg_to)
+{
+	struct dm_list *lvh, *lvht;
+	struct logical_volume *lv;
+	struct lv_segment *seg;
+	unsigned s, seg_in;
+
+	dm_list_iterate_safe(lvh, lvht, &vg_from->lvs) {
+		lv = dm_list_item(lvh, struct lv_list)->lv;
+
+		if (!lv_is_raid(lv))
+			continue;
+
+		seg = first_seg(lv);
+
+		seg_in = 0;
+		for (s = 0; s < seg->area_count; s++) {
+			if (_lv_is_in_vg(vg_to, seg_lv(seg, s)))
+				seg_in++;
+			if (_lv_is_in_vg(vg_to, seg_metalv(seg, s)))
+				seg_in++;
+		}
+
+		if (seg_in && seg_in != (seg->area_count * 2)) {
+			log_error("Can't split RAID %s between "
+				  "two Volume Groups", lv->name);
+			return 0;
+		}
+
+		if (!_move_one_lv(vg_from, vg_to, lvh))
+			return_0;
+	}
+
+	return 1;
+}
+
 static int _move_thins(struct volume_group *vg_from,
 		       struct volume_group *vg_to)
 {
@@ -547,6 +590,10 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 		goto_bad;
 
 	/* FIXME Separate the 'move' from the 'validation' to fix dev stacks */
+	/* Move required RAID across */
+	if (!(_move_raid(vg_from, vg_to)))
+		goto_bad;
+
 	/* Move required mirrors across */
 	if (!(_move_mirrors(vg_from, vg_to)))
 		goto_bad;


