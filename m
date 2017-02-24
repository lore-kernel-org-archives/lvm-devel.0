From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:02 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063202.C2B2960AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b499d96215a67711220b44fcb88693221c6d7ef5
Commit:        b499d96215a67711220b44fcb88693221c6d7ef5
Parent:        e2354ea344c248ede9faa872c260d46985830c0f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 01:18:38 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces local infrastructure to raid_manip.c
used by followup patches.

Add functions:
- to check reshaping is supported in target attibute
- to return device health string needed to check
  the raid device is ready to reshape

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |   56 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9ecc410..9c94b24 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -50,6 +50,24 @@ static int _check_num_areas_in_lv_segments(struct logical_volume *lv, unsigned n
 }
 
 /*
+ * Check if reshape is supported in the kernel.
+ */
+__attribute__ ((__unused__))
+static int _reshape_is_supported(struct cmd_context *cmd, const struct segment_type *segtype)
+{
+	unsigned attrs;
+
+	if (!segtype->ops->target_present ||
+            !segtype->ops->target_present(cmd, NULL, &attrs) ||
+            !(attrs & RAID_FEATURE_RESHAPE)) {
+		log_error("RAID module does not support reshape.");
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
  * Ensure region size exceeds the minimum for @lv because
  * MD's bitmap is limited to tracking 2^21 regions.
  *
@@ -228,6 +246,44 @@ static int _deactivate_and_remove_lvs(struct volume_group *vg, struct dm_list *r
 }
 
 /*
+ * HM Helper:
+ *
+ * report health string in @*raid_health for @lv from kernel reporting # of devs in @*kernel_devs
+ */
+__attribute__ ((__unused__))
+static int _get_dev_health(struct logical_volume *lv, uint32_t *kernel_devs,
+			   uint32_t *devs_health, uint32_t *devs_in_sync,
+			   char **raid_health)
+{
+	unsigned d;
+	char *rh;
+
+	*devs_health = *devs_in_sync = 0;
+
+	if (!lv_raid_dev_count(lv, kernel_devs)) {
+		log_error("Failed to get device count.");
+		return_0;
+	}
+
+	if (!lv_raid_dev_health(lv, &rh)) {
+		log_error("Failed to get device health.");
+		return_0;
+	}
+
+	d = (unsigned) strlen(rh);
+	while (d--) {
+		(*devs_health)++;
+		if (rh[d] == 'A')
+			(*devs_in_sync)++;
+	}
+
+	if (raid_health)
+		*raid_health = rh;
+
+	return 1;
+}
+
+/*
  * _raid_in_sync
  * @lv
  *


