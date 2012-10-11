From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 11 Oct 2012 11:58:47 -0500
Subject: [PATCH] RAID: Make RAID 4/5/6 display sync status under heading s/Copy%/Cpy%Sync
Message-ID: <1349974727.25910.2.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RAID: Make RAID 4/5/6 display sync status under heading s/Copy%/Cpy%Sync

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

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: lvm2/lib/report/columns.h
===================================================================
--- lvm2.orig/lib/report/columns.h
+++ lvm2/lib/report/columns.h
@@ -78,7 +78,7 @@ FIELD(LVS, lv, NUM, "OSize", lvid, 5, or
 FIELD(LVS, lv, NUM, "Data%", lvid, 6, datapercent, data_percent, "For snapshot and thin pools and volumes, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Snap%", lvid, 6, snpercent, snap_percent, "For snapshots, the percentage full if LV is active.", 0)
 FIELD(LVS, lv, NUM, "Meta%", lvid, 6, metadatapercent, metadata_percent, "For thin pools, the percentage of metadata full if LV is active.", 0)
-FIELD(LVS, lv, NUM, "Copy%", lvid, 6, copypercent, copy_percent, "For mirrors and pvmove, current percentage in-sync.", 0)
+FIELD(LVS, lv, NUM, "Cpy%Sync", lvid, 8, copypercent, copy_percent, "For RAID, mirrors and pvmove, current percentage in-sync.", 0)
 FIELD(LVS, lv, STR, "Move", lvid, 4, movepv, move_pv, "For pvmove, Source PV of temporary LV created by pvmove.", 0)
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
Index: lvm2/lib/report/report.c
===================================================================
--- lvm2.orig/lib/report/report.c
+++ lvm2/lib/report/report.c
@@ -899,13 +899,14 @@ static int _copypercent_disp(struct dm_r
 		return 0;
 	}
 
-	if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
-	    !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent,
-			       NULL) || (percent == PERCENT_INVALID)) {
-		*sortval = UINT64_C(0);
-		dm_report_field_set_value(field, "", sortval);
-		return 1;
-	}
+	if (seg_is_raid(first_seg(lv))) {
+		if (!lv_raid_percent(lv, &percent) ||
+		    (percent == PERCENT_INVALID))
+			goto no_copypercent;
+	} else if ((!(lv->status & PVMOVE) && !(lv->status & MIRRORED)) ||
+		   !lv_mirror_percent(lv->vg->cmd, lv, 0, &percent, NULL) ||
+		   (percent == PERCENT_INVALID))
+		goto no_copypercent;
 
 	percent = copy_percent(lv);
 
@@ -923,6 +924,11 @@ static int _copypercent_disp(struct dm_r
 	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
+
+no_copypercent:
+	*sortval = UINT64_C(0);
+	dm_report_field_set_value(field, "", sortval);
+	return 1;
 }
 
 static int _dtpercent_disp(int metadata, struct dm_report *rh,



