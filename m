From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 14 Jun 2017 09:42:01 -0400
Subject: master - lvconvert: Disallow removal of primary when up-converting (recovering)
Message-ID: <201706141342.v5EDg1in012800@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddb14b6b05e0f75a97ab8ab1ed99091268c239ba
Commit:        ddb14b6b05e0f75a97ab8ab1ed99091268c239ba
Parent:        4c0e908b0ac012a5517e61420ea1eccc6193c00a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 14 08:41:05 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 14 08:41:05 2017 -0500

lvconvert: Disallow removal of primary when up-converting (recovering)

This patch ensures that under normal conditions (i.e. not during repair
operations) that users are prevented from removing devices that would
cause data loss.

When a RAID1 is undergoing its initial sync, it is ok to remove all but
one of the images because they have all existed since creation and
contain all the data written since the array was created.  OTOH, if the
RAID1 was created as a result of an up-convert from linear, it is very
important not to let the user remove the primary image (the source of
all the data).  They should be allowed to remove any devices they want
and as many as they want as long as one original (primary) device is left
during a "recover" (aka up-convert).

This fixes bug 1461187 and includes the necessary regression tests.
---
 lib/metadata/raid_manip.c    |   85 ++++++++++++++++++++++++++++++++++++++++++
 test/shell/lvconvert-raid.sh |   61 ++++++++++++++++++++++++++++++
 2 files changed, 146 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0925594..52def78 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2862,6 +2862,87 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 }
 
 /*
+ * _raid_allow_extraction
+ * @lv
+ * @extract_count
+ * @target_pvs
+ *
+ * returns: 0 if no, 1 if yes
+ */
+static int _raid_allow_extraction(struct logical_volume *lv,
+				  int extract_count,
+				  struct dm_list *target_pvs)
+{
+	int s, redundancy = 0;
+	char *dev_health;
+	char *sync_action;
+	struct lv_segment *seg = first_seg(lv);
+	struct cmd_context *cmd = lv->vg->cmd;
+
+	/* If in-sync or hanlding repairs, allow to proceed. */
+	if (_raid_in_sync(lv) || lv->vg->cmd->handles_missing_pvs)
+		return 1;
+
+	/*
+	 * FIXME:
+	 * Right now, we are primarily concerned with down-converting of
+	 * RAID1 LVs, but parity RAIDs and RAID10 will also have to be
+	 * considered.
+	 * (e.g. It would not be good to allow extracting a dev from a
+	 * stripe set while upconverting to RAID5/6.)
+	 */
+	if (!segtype_is_raid1(seg->segtype))
+		return 1;
+
+	/*
+	 * We can allow extracting images if the array is performing a
+	 * sync operation as long as it is "recover" and the image is not
+	 * a primary image or if "resync".
+	 */
+	if (!lv_raid_sync_action(lv, &sync_action) ||
+	    !lv_raid_dev_health(lv, &dev_health))
+		return_0;
+
+	if (!strcmp("idle", sync_action)) {
+		log_error(INTERNAL_ERROR
+			  "RAID LV should not be out-of-sync and \"idle\"");
+		return 0;
+	}
+
+	if (!strcmp("resync", sync_action))
+		return 1;
+
+	/* If anything other than "recover" */
+	if (strcmp("recover", sync_action)) {
+		log_error("Unable to remove RAID image while array"
+			  " is performing \"%s\"", sync_action);
+		return 0;
+	}
+
+	if (seg->area_count != strlen(dev_health)) {
+		log_error(INTERNAL_ERROR
+			  "RAID LV area_count differs from number of health characters");
+		return 0;
+	}
+
+	for (s = 0; s < seg->area_count; s++)
+		if (dev_health[s] == 'A')
+			redundancy++;
+
+	for (s = 0; (s < seg->area_count) && extract_count; s++) {
+		if (!lv_is_on_pvs(seg_lv(seg, s), target_pvs) &&
+		    !lv_is_on_pvs(seg_metalv(seg, s), target_pvs))
+			continue;
+		if ((dev_health[s] == 'A') && !--redundancy) {
+			log_error("Unable to remove all primary source devices");
+			return 0;
+		}
+		extract_count--;
+	}
+	return 1;
+}
+
+/*
  * _raid_extract_images
  * @lv
  * @force: force a replacement in case of primary mirror leg
@@ -2892,6 +2973,10 @@ static int _raid_extract_images(struct logical_volume *lv,
 	struct segment_type *error_segtype;
 
 	extract = seg->area_count - new_count;
+
+	if (!_raid_allow_extraction(lv, extract, target_pvs))
+		return_0;
+
 	log_verbose("Extracting %u %s from %s.", extract,
 		    (extract > 1) ? "images" : "image",
 		    display_lvname(lv));
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index e173d66..fba7864 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -223,6 +223,67 @@ for i in 1 2 3 ; do
 done
 
 ###########################################
+# Upconverted RAID1 should not allow loss of primary
+#  - don't allow removal of primary while syncing
+#  - DO allow removal of secondaries while syncing
+###########################################
+aux delay_dev $dev2 0 100
+lvcreate -aey -l 2 -n $lv1 $vg $dev1 $dev2
+lvconvert -y -m 1 $vg/$lv1 \
+	--config 'global { mirror_segtype_default = "raid1" }'
+lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
+not lvconvert --yes -m 0 $vg/$lv1 $dev1
+lvconvert --yes -m 0 $vg/$lv1 $dev2
+aux enable_dev $dev2
+lvremove -ff $vg
+
+###########################################
+# lvcreated RAID1 should allow all down-conversion
+#  - DO allow removal of primary while syncing
+#  - DO allow removal of secondaries while syncing
+###########################################
+aux delay_dev $dev2 0 100
+lvcreate --type raid1 -m 2 -aey -l 2 -n $lv1 $vg $dev1 $dev2 $dev3
+lvconvert --yes -m 1 $vg/$lv1 $dev3
+lvconvert --yes -m 0 $vg/$lv1 $dev1
+aux enable_dev $dev2
+lvremove -ff $vg
+
+###########################################
+# Converting from 2-way RAID1 to 3-way
+#  - DO allow removal of one of primary sources
+#  - Do not allow removal of all primary sources
+###########################################
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
+aux wait_for_sync $vg $lv1
+aux delay_dev $dev3 0 100
+lvconvert --yes -m +1 $vg/$lv1 $dev3
+# should allow 1st primary to be removed
+lvconvert --yes -m -1 $vg/$lv1 $dev1
+# should NOT allow last primary to be removed
+not lvconvert --yes -m -1 $vg/$lv1 $dev2
+# should allow non-primary to be removed
+lvconvert --yes -m 0 $vg/$lv1 $dev3
+aux enable_dev $dev3
+lvremove -ff $vg
+
+###########################################
+# Converting from 2-way RAID1 to 3-way
+#  - Should allow removal of two devices,
+#    as long as they aren't both primary
+###########################################
+lvcreate --type raid1 -m 1 -aey -l 2 -n $lv1 $vg $dev1 $dev2
+aux wait_for_sync $vg $lv1
+aux delay_dev $dev3 0 100
+lvconvert --yes -m +1 $vg/$lv1 $dev3
+# should NOT allow both primaries to be removed
+not lvconvert -m 0 $vg/$lv1 $dev1 $dev2
+# should allow primary + non-primary
+lvconvert --yes -m 0 $vg/$lv1 $dev1 $dev3
+aux enable_dev $dev3
+lvremove -ff $vg
+
+###########################################
 # Device Replacement Testing
 ###########################################
 # RAID1: Replace up to n-1 devices - trying different combinations


