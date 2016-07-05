From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:19 +0000 (UTC)
Subject: master - libdm: clarify library's use of aux_data
Message-ID: <20160705185519.E46BA60F23@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fef4832a8509560293409a254c6a4e2ef39deb27
Commit:        fef4832a8509560293409a254c6a4e2ef39deb27
Parent:        2b0dd0b05173ba95920bc65a8cb4712dee5aa086
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 15:17:44 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:17 2016 +0100

libdm: clarify library's use of aux_data

Make it clear in libdevmapper.h, and in function argument names, that
libdm-stats uses the aux_data field internally and that any values set
for user_data are appended to the library values before being stored
with a region, and similarly, that internal data fields will be stripped
prior to returning any previously stored user_data.
---
 libdm/libdevmapper.h |   58 +++++++++++++++++++++++++++++++++++++++----------
 libdm/libdm-stats.c  |    4 +-
 2 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2fd8061..e769be2 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -638,9 +638,24 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
  * program creating the region. If program_id is NULL or the empty
  * string the default program_id stored in the handle will be used.
  *
- * aux_data is an optional string argument passed to the kernel that is
- * stored with the statistics region. It is not currently accessed by
- * the library or kernel and may be used to store arbitrary user data.
+ * user_data is an optional string argument that is added to the
+ * content of the aux_data field stored with the statistics region by
+ * the kernel.
+ *
+ * The library may also use this space internally, for example, to
+ * store a group descriptor or other metadata: in this case the
+ * library will strip any internal data fields from the value before
+ * it is returned via a call to dm_stats_get_region_aux_data().
+ *
+ * The user data stored is not accessed by the library or kernel and
+ * may be used to store an arbitrary data word (embedded whitespace is
+ * not permitted).
+ *
+ * An application using both the library and direct access to the
+ * @stats_list device-mapper message may see the internal values stored
+ * in this field by the library. In such cases any string up to and
+ * including the first '#' in the field must be treated as an opaque
+ * value and preserved across any external modification of aux_data.
  *
  * The region_id of the newly-created region is returned in *region_id
  * if it is non-NULL.
@@ -648,7 +663,7 @@ int dm_stats_populate(struct dm_stats *dms, const char *program_id,
 int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			   uint64_t start, uint64_t len, int64_t step,
 			   int precise, struct dm_histogram *bounds,
-			   const char *program_id, const char *aux_data);
+			   const char *program_id, const char *user_data);
 
 /*
  * Delete the specified statistics region. This will also mark the
@@ -922,16 +937,35 @@ int dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
 			     uint64_t region_id, uint64_t area_id);
 
 /*
- * Retrieve program_id and aux_data for a specific region. Only valid
- * following a call to dm_stats_list(). The returned pointer does not
- * need to be freed separately from the dm_stats handle but will become
- * invalid after a dm_stats_destroy(), dm_stats_list(),
- * dm_stats_populate(), or dm_stats_bind*() of the handle from which it
- * was obtained.
+ * Retrieve program_id and user aux_data for a specific region.
+ *
+ * Only valid following a call to dm_stats_list().
+ */
+
+/*
+ * Retrieve program_id for the specified region.
+ *
+ * The returned pointer does not need to be freed separately from the
+ * dm_stats handle but will become invalid after a dm_stats_destroy(),
+ * dm_stats_list(), dm_stats_populate(), or dm_stats_bind*() of the
+ * handle from which it was obtained.
  */
 const char *dm_stats_get_region_program_id(const struct dm_stats *dms,
 					   uint64_t region_id);
 
+/*
+ * Retrieve user aux_data set for the specified region. This function
+ * will return any stored user aux_data as a string in the memory
+ * pointed to by the aux_data argument.
+ *
+ * Any library internal aux_data fields, such as DMS_GROUP descriptors,
+ * are stripped before the value is returned.
+ *
+ * The returned pointer does not need to be freed separately from the
+ * dm_stats handle but will become invalid after a dm_stats_destroy(),
+ * dm_stats_list(), dm_stats_populate(), or dm_stats_bind*() of the
+ * handle from which it was obtained.
+ */
 const char *dm_stats_get_region_aux_data(const struct dm_stats *dms,
 					 uint64_t region_id);
 
@@ -1184,8 +1218,8 @@ int dm_stats_get_current_area_len(const struct dm_stats *dms,
 const char *dm_stats_get_current_region_program_id(const struct dm_stats *dms);
 
 /*
- * Return a pointer to the aux_data string for the region at the current
- * cursor location.
+ * Return a pointer to the user aux_data string for the region at the
+ * current cursor location.
  */
 const char *dm_stats_get_current_region_aux_data(const struct dm_stats *dms);
 
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index e1f05c7..93b8e0b 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1930,7 +1930,7 @@ out:
 int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 			   uint64_t start, uint64_t len, int64_t step,
 			   int precise, struct dm_histogram *bounds,
-			   const char *program_id, const char *aux_data)
+			   const char *program_id, const char *user_data)
 {
 	char *hist_arg = NULL;
 	int r = 0;
@@ -1946,7 +1946,7 @@ int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
 	}
 
 	r = _stats_create_region(dms, region_id, start, len, step,
-				 precise, hist_arg, program_id, aux_data);
+				 precise, hist_arg, program_id, user_data);
 	dm_free(hist_arg);
 
 out:


