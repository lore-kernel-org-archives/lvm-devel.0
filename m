From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:19 -0500
Subject: [PATCH 16/21] Add vg get/set methods for metadata balance min/max.
In-Reply-To: <1265754744-17319-16-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-11-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-12-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-13-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-14-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-15-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-16-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-17-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds the get and partially implemented set functions.
The 'set' functions should probably enable or disable metadata areas
based on new values.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    4 +++
 lib/metadata/metadata.c          |   55 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a40ffe4..8978838 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -758,6 +758,10 @@ uint64_t vg_max_pv(const struct volume_group *vg);
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_count_disabled(const struct volume_group *vg);
+uint32_t vg_mda_balance_min(const struct volume_group *vg);
+uint32_t vg_mda_balance_max(const struct volume_group *vg);
+int vg_set_mda_balance_min(struct volume_group *vg, uint32_t value);
+int vg_set_mda_balance_max(struct volume_group *vg, uint32_t value);
 int vg_check_write_mode(struct volume_group *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 #define vg_is_exported(vg) (vg_status((vg)) & EXPORTED_VG)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6fe8008..66f404f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -913,6 +913,61 @@ static int _recalc_extents(uint32_t *extents, const char *desc1,
 	return 1;
 }
 
+uint32_t vg_mda_balance_min(const struct volume_group *vg)
+{
+	return vg->metadata_balance_min;
+}
+
+uint32_t vg_mda_balance_max(const struct volume_group *vg)
+{
+	return vg->metadata_balance_max;
+}
+
+int vg_set_mda_balance_min(struct volume_group *vg, uint32_t value)
+{
+	/* FIXME: add checks, etc, and set the value */
+	if (value < 1) {
+		log_error("Metadata balance min must be greater "
+			  "than 0");
+		return 0;
+	}
+	if (value > vg_mda_balance_max(vg)) {
+		log_error("Metadata balance min must not be larger "
+			  "than metadata balance max (%u).",
+			  vg_mda_balance_max(vg));
+		return 0;
+	}
+	/*
+	 * FIXME: Before we set a larger value, we may need to
+	 * enable some mdas on PVS
+	 */
+	vg->metadata_balance_min = value;
+	return 1;
+}
+
+int vg_set_mda_balance_max(struct volume_group *vg, uint32_t value)
+{
+	/* FIXME: add checks, etc, and set the value */
+	/* FIXME: allow special value to be equivalent to all PVs */
+	if (value > dm_list_size(&vg->pvs)) {
+		log_error("Metadata balance max must be no greater "
+			  "than the number of physical volumes (%u) "
+			  "in the volume group", dm_list_size(&vg->pvs));
+		return 0;
+	}
+	if (value < vg_mda_balance_min(vg)) {
+		log_error("Metadata balance max must not be smaller "
+			  "than metadata balance min.");
+		return 0;
+	}
+	/*
+	 * FIXME: Before we set a smaller value, we may need to
+	 * disable some mdas on PVS
+	 */
+	vg->metadata_balance_max = value;
+	return 1;
+}
+
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
-- 
1.6.0.6


