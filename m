From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 24 Oct 2012 02:21:01 +0000 (UTC)
Subject: master - RAID: Make RAID 4/5/6 display sync status under heading s/Copy%/Cpy%Sync
Message-ID: <20121024022101.D70B02329@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1917809477c4850cc1094121001d61a2b70ef26
Commit:        e1917809477c4850cc1094121001d61a2b70ef26
Parent:        6db461e3b0d3fbc394fe2ed2a7d6a3c070453874
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Oct 23 21:19:27 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Oct 23 21:19:27 2012 -0500

RAID:  Make RAID 4/5/6 display sync status under heading s/Copy%/Cpy%Sync

The heading 'Copy%' is specific to PVMOVE volumes, but can be generalized
to apply to LVM mirrors also.  It is a bit awkward to use 'Copy%' for
RAID 4/5/6, however - 'Sync%' would be more appropriate.  This is why
RAID 4/5/6 have not displayed their sync status by any means available to
'lvs' yet.

Example (old):
[root at hayes-02 lvm2]# lvs vg
  LV      VG   Attr      LSize  Pool Origin Data%  Move Log Cpy%Sy Convert
  lv    vg   -wi-a----  1.00g
  raid1 vg   rwi-a-r--  1.00g                             100.00
  raid4 vg   rwi-a-r--  1.01g
  raid5 vg   rwi-a-r--  1.01g
  raid6 vg   rwi-a-r--  1.01g

This patch changes the heading to 'Cpy%Sync' and allows RAID 4/5/6 to print
their sync percent in this field.

Example (new):
[root at hayes-02 lvm2]# lvs vg
  LV    VG   Attr      LSize Pool Origin Data%  Move Log Cpy%Sync Convert
  lv    vg   -wi-a---- 1.00g
  raid1 vg   rwi-a-r-- 1.00g                               100.00
  raid4 vg   rwi-a-r-- 1.01g                               100.00
  raid5 vg   rwi-a-r-- 1.01g                               100.00
  raid6 vg   rwi-a-r-- 1.01g                               100.00
---
 lib/report/columns.h    |    3 ++-
 lib/report/properties.c |    2 ++
 lib/report/report.c     |   20 +++++++++++++-------
 man/lvs.8.in            |    1 +
 4 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 6299a2b..c83a086 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -78,7 +78,8 @@ FIELD(LVS, lv, NUM, "OSize", lvid, 5, originsize, origin_size, "For snapshots, t
 FIELD(LVS, lv, NUM, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
-FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, copy_percent, "For mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, sync_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c4f6ab9..fe197f5 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -189,6 +189,8 @@ GET_LV_NUM_PROPERTY_FN(snap_percent, _snap_percent(lv))
 #define _snap_percent_set _not_implemented_set
 GET_LV_NUM_PROPERTY_FN(copy_percent, _copy_percent(lv))
 #define _copy_percent_set _not_implemented_set
+GET_LV_NUM_PROPERTY_FN(sync_percent, _copy_percent(lv))
+#define _sync_percent_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(move_pv, lv_move_pv_dup(lv->vg->vgmem, lv))
 #define _move_pv_set _not_implemented_set
 GET_LV_STR_PROPERTY_FN(convert_lv, lv_convert_lv_dup(lv->vg->vgmem, lv))
diff --git a/lib/report/report.c b/lib/report/report.c
index b1e2bc1..1833458 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -898,13 +898,14 @@ static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
 		return 0;
 	}
 
-	if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
-	    !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent,
-			       NULL) || (percent == PERCENT_INVALID)) {
-		*sortval = UINT64_C(0);
-		dm_report_field_set_value(field, "", sortval);
-		return 1;
-	}
+	if (lv->status & RAID) {
+		if (!lv_raid_percent(lv, &percent) ||
+		    (percent == PERCENT_INVALID))
+			goto no_copypercent;
+	} else if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
+		   !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL) ||
+		   (percent == PERCENT_INVALID))
+		goto no_copypercent;
 
 	percent = copy_percent(lv);
 
@@ -922,6 +923,11 @@ static int _copypercent_disp(struct dm_report *rh __attribute__((unused)),
 	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
+
+no_copypercent:
+	*sortval = UINT64_C(0);
+	dm_report_field_set_value(field, "", sortval);
+	return 1;
 }
 
 static int _dtpercent_disp(int metadata, struct dm_report *rh,
diff --git a/man/lvs.8.in b/man/lvs.8.in
index f31256c..d4d77b0 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -113,6 +113,7 @@ seg_tags,
 snap_percent,
 stripes,
 stripe_size,
+sync_percent,
 thin_count,
 transaction_id,
 zero.


