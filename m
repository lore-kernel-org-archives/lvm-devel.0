From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 31 Jan 2013 16:53:11 -0600
Subject: [PATCH 3 of 3] Improve attribute reporting of RAID LVs via 'lvs'
Message-ID: <1359672791.13305.14.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

RAID:  Improve the attribute reporting of RAID LVs and sub-LVs

There are currently a few issues with the reporting done on RAID LVs and
sub-LVs.  The most concerning is that 'lvs' does not always report the
correct failure status of individual RAID sub-LVs (devices).  This can
occur when a device fails and is restored after the failure has been
detected by the kernel.  In this case, 'lvs' would report all devices are
fine because it can read the labels on each device just fine.
Example:
[root at bp-01 lvm2]# lvs -a -o name,vg_name,attr,copy_percent,devices vg
  LV            VG   Attr      Cpy%Sync Devices                      
  lv            vg   rwi-a-r--   100.00 lv_rimage_0(0),lv_rimage_1(0)
  [lv_rimage_0] vg   iwi-aor--          /dev/sda1(1)                 
  [lv_rimage_1] vg   iwi-aor--          /dev/sdb1(1)                 
  [lv_rmeta_0]  vg   ewi-aor--          /dev/sda1(0)                 
  [lv_rmeta_1]  vg   ewi-aor--          /dev/sdb1(0)                 

However, 'dmsetup status' on the device tells us a different story:
  [root at bp-01 lvm2]# dmsetup status vg-lv
  0 1024000 raid raid1 2 DA 1024000/1024000

In this case, we must also be sure to check the RAID LVs kernel status
in order to get the proper information.  Here is an example of the correct
output that is displayed after this patch is applied:
[root at bp-01 lvm2]# lvs -a -o name,vg_name,attr,copy_percent,devices vg
  LV            VG   Attr      Cpy%Sync Devices                      
  lv            vg   rwi-a-r-p   100.00 lv_rimage_0(0),lv_rimage_1(0)
  [lv_rimage_0] vg   iwi-aor-p          /dev/sda1(1)                 
  [lv_rimage_1] vg   iwi-aor--          /dev/sdb1(1)                 
  [lv_rmeta_0]  vg   ewi-aor-p          /dev/sda1(0)                 
  [lv_rmeta_1]  vg   ewi-aor--          /dev/sdb1(0)                 


The other case where 'lvs' gives incomplete or improper output is when a
device is replaced or added to a RAID LV.  It should display that the RAID
LV is in the process of sync'ing and that the new device is the only one
that is not-in-sync - as indicated by a leading 'I' in the Attr column.
(Remember that 'i' indicates an (i)mage that is in-sync and 'I' indicates
an (I)mage that is not in sync.)  Here's an example of the old incorrect
behaviour:
[root at bp-01 lvm2]# lvs -a -o name,vg_name,attr,copy_percent,devices vg
  LV            VG   Attr      Cpy%Sync Devices                      
  lv            vg   rwi-a-r--   100.00 lv_rimage_0(0),lv_rimage_1(0)
  [lv_rimage_0] vg   iwi-aor--          /dev/sda1(1)                 
  [lv_rimage_1] vg   iwi-aor--          /dev/sdb1(1)                 
  [lv_rmeta_0]  vg   ewi-aor--          /dev/sda1(0)                 
  [lv_rmeta_1]  vg   ewi-aor--          /dev/sdb1(0)                 
[root at bp-01 lvm2]# lvconvert -m +1 vg/lv; lvs -a -o name,vg_name,attr,copy_percent,devices vg
  LV            VG   Attr      Cpy%Sync Devices
  lv            vg   rwi-a-r--     0.00 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0)
  [lv_rimage_0] vg   Iwi-aor--          /dev/sda1(1)
  [lv_rimage_1] vg   Iwi-aor--          /dev/sdb1(1)
  [lv_rimage_2] vg   Iwi-aor--          /dev/sdc1(1)
  [lv_rmeta_0]  vg   ewi-aor--          /dev/sda1(0)
  [lv_rmeta_1]  vg   ewi-aor--          /dev/sdb1(0)
  [lv_rmeta_2]  vg   ewi-aor--          /dev/sdc1(0)                            ** Note that all the images currently are marked as 'I' even though it is
   only the last device that has been added that should be marked.

Here is an example of the correct output after this patch is applied:
[root at bp-01 lvm2]# lvs -a -o name,vg_name,attr,copy_percent,devices vg
  LV            VG   Attr      Cpy%Sync Devices
  lv            vg   rwi-a-r--   100.00 lv_rimage_0(0),lv_rimage_1(0)
  [lv_rimage_0] vg   iwi-aor--          /dev/sda1(1)
  [lv_rimage_1] vg   iwi-aor--          /dev/sdb1(1)
  [lv_rmeta_0]  vg   ewi-aor--          /dev/sda1(0)
  [lv_rmeta_1]  vg   ewi-aor--          /dev/sdb1(0)
[root at bp-01 lvm2]# lvconvert -m +1 vg/lv; lvs -a -o name,vg_name,attr,copy_percent,devices vg
  LV            VG   Attr      Cpy%Sync Devices
  lv            vg   rwi-a-r--     0.00 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0)
  [lv_rimage_0] vg   iwi-aor--          /dev/sda1(1)
  [lv_rimage_1] vg   iwi-aor--          /dev/sdb1(1)
  [lv_rimage_2] vg   Iwi-aor--          /dev/sdc1(1)
  [lv_rmeta_0]  vg   ewi-aor--          /dev/sda1(0)
  [lv_rmeta_1]  vg   ewi-aor--          /dev/sdb1(0)
  [lv_rmeta_2]  vg   ewi-aor--          /dev/sdc1(0)                            
** Note only the last image is marked with an 'I'.  This is correct and we can
   tell that it isn't the whole array that is sync'ing, but just the new
   device.

It also works under snapshots...
[root at bp-01 lvm2]# lvs -a -o name,vg_name,attr,copy_percent,devices vg
  LV            VG   Attr      Cpy%Sync Devices                                     
  lv            vg   owi-a-r-p    33.47 lv_rimage_0(0),lv_rimage_1(0),lv_rimage_2(0)
  [lv_rimage_0] vg   iwi-aor--          /dev/sda1(1)
  [lv_rimage_1] vg   Iwi-aor-p          /dev/sdb1(1)
  [lv_rimage_2] vg   Iwi-aor--          /dev/sdc1(1)
  [lv_rmeta_0]  vg   ewi-aor--          /dev/sda1(0)
  [lv_rmeta_1]  vg   ewi-aor-p          /dev/sdb1(0)
  [lv_rmeta_2]  vg   ewi-aor--          /dev/sdc1(0)
  snap          vg   swi-a-s--          /dev/sda1(51201)                            


Index: lvm2/lib/metadata/lv.c
===================================================================
--- lvm2.orig/lib/metadata/lv.c
+++ lvm2/lib/metadata/lv.c
@@ -339,9 +339,15 @@ static int _lv_mimage_in_sync(const stru
 
 static int _lv_raid_image_in_sync(const struct logical_volume *lv)
 {
+	unsigned s;
 	percent_t percent;
+	char *raid_health;
 	struct lv_segment *raid_seg;
 
+	/* If the LV is not active, it doesn't make sense to check status */
+	if (!lv_is_active(lv))
+		return 0;  /* Assume not in-sync */
+
 	if (!(lv->status & RAID_IMAGE)) {
 		log_error(INTERNAL_ERROR "%s is not a RAID image", lv->name);
 		return 0;
@@ -365,20 +371,91 @@ static int _lv_raid_image_in_sync(const
 	if (percent == PERCENT_100)
 		return 1;
 
-	/*
-	 * FIXME:  Get individual RAID image status.
-	 * The status health characters reported from a RAID target
-	 * indicate whether the whole array or just individual devices
-	 * are in-sync.  If the corresponding character for this image
-	 * was 'A', we could report a more accurate status.  This is
-	 * especially so in the case of failures or rebuildings.
-	 *
-	 * We need to test the health characters anyway to report
-	 * the correct 4th attr character.  Just need to figure out
-	 * where to put this functionality.
-	 */
+	/* Find out which sub-LV this is. */
+	for (s = 0; s < raid_seg->area_count; s++)
+		if (seg_lv(raid_seg, s) == lv)
+			break;
+	if (s == raid_seg->area_count) {
+		log_error(INTERNAL_ERROR
+			  "sub-LV %s was not found in raid segment",
+			  lv->name);
+		return 0;
+	}
+
+	if (!lv_raid_dev_health(raid_seg->lv, &raid_health))
+		return_0;
+
+	if (raid_health[s] == 'A')
+		return 1;
+
 	return 0;
 }
+
+/*
+ * _lv_raid_healthy
+ * @lv: A RAID_IMAGE, RAID_META, or RAID logical volume.
+ *
+ * Returns: 1 if healthy, 0 if device is not health
+ */
+static int _lv_raid_healthy(const struct logical_volume *lv)
+{
+	unsigned s;
+	char *raid_health;
+	struct lv_segment *raid_seg;
+
+	/* If the LV is not active, it doesn't make sense to check status */
+	if (!lv_is_active(lv))
+		return 1;  /* assume healthy */
+
+	if (!lv_is_raid_type(lv)) {
+		log_error(INTERNAL_ERROR "%s is not of RAID type", lv->name);
+		return 0;
+	}
+
+	if (lv->status & RAID)
+		raid_seg = first_seg(lv);
+	else
+		raid_seg = get_only_segment_using_this_lv(first_seg(lv)->lv);
+
+	if (!raid_seg) {
+		log_error("Failed to find RAID segment for %s", lv->name);
+		return 0;
+	}
+
+	if (!seg_is_raid(raid_seg)) {
+		log_error("%s on %s is not a RAID segment",
+			  raid_seg->lv->name, lv->name);
+		return 0;
+	}
+
+	if (!lv_raid_dev_health(raid_seg->lv, &raid_health))
+		return_0;
+
+	if (lv->status & RAID) {
+		if (strchr(raid_health, 'D'))
+			return 0;
+		else
+			return 1;
+	}
+
+	/* Find out which sub-LV this is. */
+	for (s = 0; s < raid_seg->area_count; s++)
+		if (((lv->status & RAID_IMAGE) && (seg_lv(raid_seg, s) == lv)) ||
+		    ((lv->status & RAID_META) && (seg_metalv(raid_seg,s) == lv)))
+			break;
+	if (s == raid_seg->area_count) {
+		log_error(INTERNAL_ERROR
+			  "sub-LV %s was not found in raid segment",
+			  lv->name);
+		return 0;
+	}
+
+	if (raid_health[s] == 'D')
+		return 0;
+
+	return 1;
+}
+
 char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	percent_t snap_percent;
@@ -505,7 +582,8 @@ char *lv_attr_dup(struct dm_pool *mem, c
 	else
 		repstr[7] = '-';
 
-	if (lv->status & PARTIAL_LV)
+	if (lv->status & PARTIAL_LV ||
+	    (lv_is_raid_type(lv) && !_lv_raid_healthy(lv)))
 		repstr[8] = 'p';
 	else
 		repstr[8] = '-';



