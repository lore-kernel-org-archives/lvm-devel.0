From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:47 +0000 (UTC)
Subject: master - metadata: add extents_from_percent_size
Message-ID: <20141030230047.4E98260DD0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bf4cd464f499403aacde52b1c1867ebb31714da
Commit:        8bf4cd464f499403aacde52b1c1867ebb31714da
Parent:        375d7f1c2d4ebe86cb54fce454f503758e02bb7a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 30 23:43:12 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

metadata: add extents_from_percent_size

Add API call to calculate extents from percentage value.
Size is based in DM_PERCENT_1 units.
(Supporting decimal point number).
This commit is preparing functionality for more global
usage of % with i.e. --size option.
---
 lib/metadata/metadata-exported.h |    3 ++
 lib/metadata/metadata.c          |   61 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5ac68bf..890e808 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -733,6 +733,9 @@ int lv_update_and_reload_origin(struct logical_volume *lv);
 
 uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 			   uint32_t extent_size);
+uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list *pvh,
+				   uint32_t extents, int roundup,
+				   percent_type_t percent, uint64_t size);
 
 struct logical_volume *find_pool_lv(const struct logical_volume *lv);
 int pool_is_active(const struct logical_volume *pool_lv);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3e1b94a..2038f06 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1097,6 +1097,67 @@ uint64_t extents_from_size(struct cmd_context *cmd, uint64_t size,
 	return size / extent_size;
 }
 
+/*
+ * Converts size according to percentage with specified rounding to extents
+ *
+ * For PERCENT_NONE size is in standard sector units.
+ * For all other percent type is in DM_PERCENT_1 base unit (supports decimal point)
+ *
+ * Return value of 0 extents is an error.
+ */
+uint32_t extents_from_percent_size(struct volume_group *vg, const struct dm_list *pvh,
+				   uint32_t extents, int roundup,
+				   percent_type_t percent, uint64_t size)
+{
+	uint32_t count;
+
+	switch (percent) {
+	case PERCENT_NONE:
+		if (!roundup && (size % vg->extent_size)) {
+			if (!(size -= size % vg->extent_size)) {
+				log_error("Specified size is smaller then physical extent boundary.");
+				return 0;
+			}
+			log_print_unless_silent("Rounding size to boundary between physical extents: %s.",
+						display_size(vg->cmd, size));
+		}
+		return extents_from_size(vg->cmd, size, vg->extent_size);
+	case PERCENT_LV:
+		break;	/* Base extents already passed in. */
+	case PERCENT_VG:
+		extents = vg->extent_count;
+		break;
+	case PERCENT_PVS:
+		if (pvh != &vg->pvs) {
+			/* Physical volumes are specified on cmdline */
+			if (!(extents = pv_list_extents_free(pvh))) {
+				log_error("No free extents in the list of physical volumes.");
+				return 0;
+			}
+			break;
+		}
+		/* Fall back to use all PVs in VG like %FREE */
+	case PERCENT_FREE:
+		if (!(extents = vg->free_count)) {
+			log_error("No free extents in Volume group %s.", vg->name);
+			return 0;
+		}
+		break;
+	default:
+		log_error(INTERNAL_ERROR "Unsupported percent type %u.", percent);
+		return 0;
+	}
+
+	if (!(count = percent_of_extents(size, extents, roundup)))
+		log_error("Converted  %.2f%%%s into 0 extents.",
+			  (double) size / DM_PERCENT_1, get_percent_string(percent));
+	else
+		log_verbose("Converted %.2f%%%s into %" PRIu32 " extents.",
+			    (double) size / DM_PERCENT_1, get_percent_string(percent), count);
+
+	return count;
+}
+
 static dm_bitset_t _bitset_with_random_bits(struct dm_pool *mem, uint32_t num_bits,
 					    uint32_t num_set_bits, unsigned *seed)
 {


