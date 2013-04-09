From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 08 Apr 2013 20:44:01 -0500
Subject: [PATCH 2 of 4] LVM RAID: Update lv_attr field to indicate more RAID states
Message-ID: <1365471841.13988.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'lvs':  Change 'p'artial lv_attr character to report volume health

This patch expands the role of the 'p'artial character in the lv_attr
report field.  "Partial" is really an indicator for the health of a
logical volume and it makes sense to extend this include other heath
indicators as well.  Specifically for this patch:
	'm'ismatches:  Indicates that there are discrepancies in a RAID
                       LV.  This character is shown after a scrubbing
                       operation has detected that portions of the RAID
                       are not coherent.
	'r'efresh   :  Indicates that a device in a RAID array has suffered
                       a failure and the kernel regards it as failed -
                       even though LVM can read the device label and
                       considers the device to be ok.  The LV should be
                       'r'efreshed to notify the kernel that the device is
                       now available, or the device should be 'r'eplaced
                       if it is suspected of failing.
                       
Index: lvm2/lib/activate/activate.c
===================================================================
--- lvm2.orig/lib/activate/activate.c
+++ lvm2/lib/activate/activate.c
@@ -183,6 +183,10 @@ int lv_raid_dev_health(const struct logi
 {
 	return 0;
 }
+int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
+{
+	return 0;
+}
 int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
@@ -800,7 +804,7 @@ int lv_raid_dev_health(const struct logi
 	*dev_health = NULL;
 
 	if (!activation())
-		return 0;
+		return_0;
 
 	log_debug_activation("Checking raid device health for LV %s/%s",
 			     lv->vg->name, lv->name);
@@ -824,6 +828,36 @@ int lv_raid_dev_health(const struct logi
 	return r;
 }
 
+int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt)
+{
+	struct dev_manager *dm;
+	struct dm_status_raid *status;
+
+	*cnt = 0;
+
+	if (!activation())
+		return 0;
+
+	log_debug_activation("Checking raid mismatch count for LV %s/%s",
+			     lv->vg->name, lv->name);
+
+	if (!lv_is_active(lv))
+		return_0;
+
+	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
+		return_0;
+
+	if (!dev_manager_raid_status(dm, lv, &status)) {
+		dev_manager_destroy(dm);
+		return_0;
+	}
+	*cnt = status->mismatch_count;
+
+	dev_manager_destroy(dm);
+
+	return 1;
+}
+
 int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	int r = 0;
Index: lvm2/lib/activate/activate.h
===================================================================
--- lvm2.orig/lib/activate/activate.h
+++ lvm2/lib/activate/activate.h
@@ -117,6 +117,7 @@ int lv_mirror_percent(struct cmd_context
 		      int wait, percent_t *percent, uint32_t *event_nr);
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
 int lv_raid_dev_health(const struct logical_volume *lv, char **dev_health);
+int lv_raid_mismatch_count(const struct logical_volume *lv, uint64_t *cnt);
 int lv_raid_message(const struct logical_volume *lv, const char *msg);
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 percent_t *percent);
Index: lvm2/lib/metadata/lv.c
===================================================================
--- lvm2.orig/lib/metadata/lv.c
+++ lvm2/lib/metadata/lv.c
@@ -597,11 +597,17 @@ char *lv_attr_dup(struct dm_pool *mem, c
 	else
 		repstr[7] = '-';
 
-	if (lv->status & PARTIAL_LV ||
-	    (lv_is_raid_type(lv) && !_lv_raid_healthy(lv)))
+	repstr[8] = '-';
+	if (lv->status & PARTIAL_LV)
 		repstr[8] = 'p';
-	else
-		repstr[8] = '-';
+	else if (lv_is_raid_type(lv)) {
+		uint64_t n;
+		if (!_lv_raid_healthy(lv))
+			repstr[8] = 'r';  /* RAID needs 'r'efresh */
+		else if ((lv->status & RAID) &&
+			 lv_raid_mismatch_count(lv, &n) && n)
+			repstr[8] = 'm';  /* RAID contains 'm'ismatches */
+	}
 
 out:
 	return repstr;
Index: lvm2/man/lvs.8.in
===================================================================
--- lvm2.orig/man/lvs.8.in
+++ lvm2/man/lvs.8.in
@@ -159,8 +159,18 @@ snapshots of thin volumes using the new
 .IP 8 3
 Newly-allocated data blocks are overwritten with blocks of (z)eroes before use.
 .IP 9 3
-(p)artial: One or more of the Physical Volumes this Logical Volume uses is
-missing from the system.
+Volume Health: (p)artial, (r)efresh needed, (m)ismatches exist.
+(p)artial signifies that one or more of the Physical Volumes this Logical
+Volume uses is missing from the system.  (r)efresh signifies that one or
+more of the Physical Volumes this RAID Logical Volume uses had suffered a
+write error.  The write error could be due to a temporary failure of that
+Physical Volume or an indication that it is failing.  The device should be
+refreshed or replaced.  (m)ismatches signifies that the RAID logical volume
+has portions of the array that are not coherent or that the array has
+recently repaired inconsistencies.  An additional "check" after a "repair"
+of a RAID logical volume will clear this flag if no additional discrepancies
+are found.  ("check" and "repair" of a RAID Logical Volume can be done via
+the 'lvchange' command.)
 .RE
 .TP
 .BR \-O ", " \-\-sort



