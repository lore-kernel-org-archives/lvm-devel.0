From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Apr 2020 18:10:00 +0000 (GMT)
Subject: master - move pv_list code into lib
Message-ID: <20200415181000.7CA3A385DC23@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6b4ad8e28eff7476cb04c4cb93312b06605b82f
Commit:        b6b4ad8e28eff7476cb04c4cb93312b06605b82f
Parent:        0dd905c959a8f36ea627027336b6d5dafb015001
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 14 14:12:20 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 13 10:04:14 2020 -0500

move pv_list code into lib

---
 lib/Makefile.in                  |   1 +
 lib/metadata/metadata-exported.h |   4 +
 lib/metadata/pv_list.c           | 291 +++++++++++++++++++++++++++++++++++++++
 tools/toollib.c                  | 270 ------------------------------------
 tools/toollib.h                  |   9 --
 5 files changed, 296 insertions(+), 279 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index c037b4162..2a064f381 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -74,6 +74,7 @@ SOURCES =\
 	metadata/mirror.c \
 	metadata/pool_manip.c \
 	metadata/pv.c \
+	metadata/pv_list.c \
 	metadata/pv_manip.c \
 	metadata/pv_map.c \
 	metadata/raid_manip.c \
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c61c85c7e..35c12318f 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1385,4 +1385,8 @@ int vg_is_foreign(struct volume_group *vg);
 
 void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg);
 
+struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
+		                                            char **argv, int allocatable_only);
+struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl);
+
 #endif
diff --git a/lib/metadata/pv_list.c b/lib/metadata/pv_list.c
new file mode 100644
index 000000000..143b573b6
--- /dev/null
+++ b/lib/metadata/pv_list.c
@@ -0,0 +1,291 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "lib/misc/lib.h"
+#include "lib/misc/lvm-string.h"
+#include "lib/datastruct/str_list.h"
+#include "lib/device/device.h"
+#include "lib/metadata/metadata.h"
+
+/*
+ * Process physical extent range specifiers
+ */
+static int _add_pe_range(struct dm_pool *mem, const char *pvname,
+			 struct dm_list *pe_ranges, uint32_t start, uint32_t count)
+{
+	struct pe_range *per;
+
+	log_debug("Adding PE range: start PE " FMTu32 " length " FMTu32 " on %s.",
+		  start, count, pvname);
+
+	/* Ensure no overlap with existing areas */
+	dm_list_iterate_items(per, pe_ranges) {
+		if (((start < per->start) && (start + count - 1 >= per->start)) ||
+		    ((start >= per->start) &&
+			(per->start + per->count - 1) >= start)) {
+			log_error("Overlapping PE ranges specified (" FMTu32
+				  "-" FMTu32 ", " FMTu32 "-" FMTu32 ") on %s.",
+				  start, start + count - 1, per->start,
+				  per->start + per->count - 1, pvname);
+			return 0;
+		}
+	}
+
+	if (!(per = dm_pool_alloc(mem, sizeof(*per)))) {
+		log_error("Allocation of list failed.");
+		return 0;
+	}
+
+	per->start = start;
+	per->count = count;
+	dm_list_add(pe_ranges, &per->list);
+
+	return 1;
+}
+
+static int _xstrtouint32(const char *s, char **p, int base, uint32_t *result)
+{
+	unsigned long ul;
+
+	errno = 0;
+	ul = strtoul(s, p, base);
+
+	if (errno || *p == s || ul > UINT32_MAX)
+		return 0;
+
+	*result = ul;
+
+	return 1;
+}
+
+static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
+		      const char *pvname, uint32_t size)
+{
+	char *endptr;
+	uint32_t start, end, len;
+
+	/* Default to whole PV */
+	if (!c) {
+		if (!_add_pe_range(mem, pvname, pe_ranges, UINT32_C(0), size))
+			return_0;
+		return 1;
+	}
+
+	while (*c) {
+		if (*c != ':')
+			goto error;
+
+		c++;
+
+		/* Disallow :: and :\0 */
+		if (*c == ':' || !*c)
+			goto error;
+
+		/* Default to whole range */
+		start = UINT32_C(0);
+		end = size - 1;
+
+		/* Start extent given? */
+		if (isdigit(*c)) {
+			if (!_xstrtouint32(c, &endptr, 10, &start))
+				goto error;
+			c = endptr;
+			/* Just one number given? */
+			if (!*c || *c == ':')
+				end = start;
+		}
+		/* Range? */
+		if (*c == '-') {
+			c++;
+			if (isdigit(*c)) {
+				if (!_xstrtouint32(c, &endptr, 10, &end))
+					goto error;
+				c = endptr;
+			}
+		} else if (*c == '+') {	/* Length? */
+			c++;
+			if (isdigit(*c)) {
+				if (!_xstrtouint32(c, &endptr, 10, &len))
+					goto error;
+				c = endptr;
+				end = start + (len ? (len - 1) : 0);
+			}
+		}
+
+		if (*c && *c != ':')
+			goto error;
+
+		if ((start > end) || (end > size - 1)) {
+			log_error("PE range error: start extent %" PRIu32 " to "
+				  "end extent %" PRIu32 ".", start, end);
+			return 0;
+		}
+
+		if (!_add_pe_range(mem, pvname, pe_ranges, start, end - start + 1))
+			return_0;
+
+	}
+
+	return 1;
+
+      error:
+	log_error("Physical extent parsing error at %s.", c);
+	return 0;
+}
+
+static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
+			     char *colon, int allocatable_only, struct dm_list *r)
+{
+	const char *pvname;
+	struct pv_list *new_pvl = NULL, *pvl2;
+	struct dm_list *pe_ranges;
+
+	pvname = pv_dev_name(pvl->pv);
+	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
+		log_warn("WARNING: Physical volume %s not allocatable.", pvname);
+		return 1;
+	}
+
+	if (allocatable_only && is_missing_pv(pvl->pv)) {
+		log_warn("WARNING: Physical volume %s is missing.", pvname);
+		return 1;
+	}
+
+	if (allocatable_only &&
+	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
+		log_warn("WARNING: No free extents on physical volume \"%s\".", pvname);
+		return 1;
+	}
+
+	dm_list_iterate_items(pvl2, r)
+		if (pvl->pv->dev == pvl2->pv->dev) {
+			new_pvl = pvl2;
+			break;
+		}
+
+	if (!new_pvl) {
+		if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
+			log_error("Unable to allocate physical volume list.");
+			return 0;
+		}
+
+		memcpy(new_pvl, pvl, sizeof(*new_pvl));
+
+		if (!(pe_ranges = dm_pool_alloc(mem, sizeof(*pe_ranges)))) {
+			log_error("Allocation of pe_ranges list failed.");
+			return 0;
+		}
+		dm_list_init(pe_ranges);
+		new_pvl->pe_ranges = pe_ranges;
+		dm_list_add(r, &new_pvl->list);
+	}
+
+	/* Determine selected physical extents */
+	if (!_parse_pes(mem, colon, new_pvl->pe_ranges, pv_dev_name(pvl->pv),
+			pvl->pv->pe_count))
+		return_0;
+
+	return 1;
+}
+
+struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
+			    char **argv, int allocatable_only)
+{
+	struct dm_list *r;
+	struct pv_list *pvl;
+	struct dm_list tagsl, arg_pvnames;
+	char *pvname = NULL;
+	char *colon, *at_sign, *tagname;
+	int i;
+
+	/* Build up list of PVs */
+	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
+		log_error("Allocation of list failed.");
+		return NULL;
+	}
+	dm_list_init(r);
+
+	dm_list_init(&tagsl);
+	dm_list_init(&arg_pvnames);
+
+	for (i = 0; i < argc; i++) {
+		dm_unescape_colons_and_at_signs(argv[i], &colon, &at_sign);
+
+		if (at_sign && (at_sign == argv[i])) {
+			tagname = at_sign + 1;
+			if (!validate_tag(tagname)) {
+				log_error("Skipping invalid tag %s.", tagname);
+				continue;
+			}
+			dm_list_iterate_items(pvl, &vg->pvs) {
+				if (str_list_match_item(&pvl->pv->tags,
+							tagname)) {
+					if (!_create_pv_entry(mem, pvl, NULL,
+							      allocatable_only,
+							      r))
+						return_NULL;
+				}
+			}
+			continue;
+		}
+
+		pvname = argv[i];
+
+		if (colon && !(pvname = dm_pool_strndup(mem, pvname,
+					(unsigned) (colon - pvname)))) {
+			log_error("Failed to clone PV name.");
+			return NULL;
+		}
+
+		if (!(pvl = find_pv_in_vg(vg, pvname))) {
+			log_error("Physical Volume \"%s\" not found in "
+				  "Volume Group \"%s\".", pvname, vg->name);
+			return NULL;
+		}
+		if (!_create_pv_entry(mem, pvl, colon, allocatable_only, r))
+			return_NULL;
+	}
+
+	if (dm_list_empty(r))
+		log_error("No specified PVs have space available.");
+
+	return dm_list_empty(r) ? NULL : r;
+}
+
+struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
+{
+	struct dm_list *r;
+	struct pv_list *pvl, *new_pvl;
+
+	/* Build up list of PVs */
+	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
+		log_error("Allocation of list failed.");
+		return NULL;
+	}
+	dm_list_init(r);
+
+	dm_list_iterate_items(pvl, pvsl) {
+		if (!(new_pvl = dm_pool_zalloc(mem, sizeof(*new_pvl)))) {
+			log_error("Unable to allocate physical volume list.");
+			return NULL;
+		}
+
+		memcpy(new_pvl, pvl, sizeof(*new_pvl));
+		dm_list_add(r, &new_pvl->list);
+	}
+
+	return r;
+}
+
diff --git a/tools/toollib.c b/tools/toollib.c
index a5304bf63..6386a6906 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -457,276 +457,6 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name)
 	return vg_name;
 }
 
-/*
- * Process physical extent range specifiers
- */
-static int _add_pe_range(struct dm_pool *mem, const char *pvname,
-			 struct dm_list *pe_ranges, uint32_t start, uint32_t count)
-{
-	struct pe_range *per;
-
-	log_debug("Adding PE range: start PE " FMTu32 " length " FMTu32 " on %s.",
-		  start, count, pvname);
-
-	/* Ensure no overlap with existing areas */
-	dm_list_iterate_items(per, pe_ranges) {
-		if (((start < per->start) && (start + count - 1 >= per->start)) ||
-		    ((start >= per->start) &&
-			(per->start + per->count - 1) >= start)) {
-			log_error("Overlapping PE ranges specified (" FMTu32
-				  "-" FMTu32 ", " FMTu32 "-" FMTu32 ") on %s.",
-				  start, start + count - 1, per->start,
-				  per->start + per->count - 1, pvname);
-			return 0;
-		}
-	}
-
-	if (!(per = dm_pool_alloc(mem, sizeof(*per)))) {
-		log_error("Allocation of list failed.");
-		return 0;
-	}
-
-	per->start = start;
-	per->count = count;
-	dm_list_add(pe_ranges, &per->list);
-
-	return 1;
-}
-
-static int _xstrtouint32(const char *s, char **p, int base, uint32_t *result)
-{
-	unsigned long ul;
-
-	errno = 0;
-	ul = strtoul(s, p, base);
-
-	if (errno || *p == s || ul > UINT32_MAX)
-		return 0;
-
-	*result = ul;
-
-	return 1;
-}
-
-static int _parse_pes(struct dm_pool *mem, char *c, struct dm_list *pe_ranges,
-		      const char *pvname, uint32_t size)
-{
-	char *endptr;
-	uint32_t start, end, len;
-
-	/* Default to whole PV */
-	if (!c) {
-		if (!_add_pe_range(mem, pvname, pe_ranges, UINT32_C(0), size))
-			return_0;
-		return 1;
-	}
-
-	while (*c) {
-		if (*c != ':')
-			goto error;
-
-		c++;
-
-		/* Disallow :: and :\0 */
-		if (*c == ':' || !*c)
-			goto error;
-
-		/* Default to whole range */
-		start = UINT32_C(0);
-		end = size - 1;
-
-		/* Start extent given? */
-		if (isdigit(*c)) {
-			if (!_xstrtouint32(c, &endptr, 10, &start))
-				goto error;
-			c = endptr;
-			/* Just one number given? */
-			if (!*c || *c == ':')
-				end = start;
-		}
-		/* Range? */
-		if (*c == '-') {
-			c++;
-			if (isdigit(*c)) {
-				if (!_xstrtouint32(c, &endptr, 10, &end))
-					goto error;
-				c = endptr;
-			}
-		} else if (*c == '+') {	/* Length? */
-			c++;
-			if (isdigit(*c)) {
-				if (!_xstrtouint32(c, &endptr, 10, &len))
-					goto error;
-				c = endptr;
-				end = start + (len ? (len - 1) : 0);
-			}
-		}
-
-		if (*c && *c != ':')
-			goto error;
-
-		if ((start > end) || (end > size - 1)) {
-			log_error("PE range error: start extent %" PRIu32 " to "
-				  "end extent %" PRIu32 ".", start, end);
-			return 0;
-		}
-
-		if (!_add_pe_range(mem, pvname, pe_ranges, start, end - start + 1))
-			return_0;
-
-	}
-
-	return 1;
-
-      error:
-	log_error("Physical extent parsing error at %s.", c);
-	return 0;
-}
-
-static int _create_pv_entry(struct dm_pool *mem, struct pv_list *pvl,
-			     char *colon, int allocatable_only, struct dm_list *r)
-{
-	const char *pvname;
-	struct pv_list *new_pvl = NULL, *pvl2;
-	struct dm_list *pe_ranges;
-
-	pvname = pv_dev_name(pvl->pv);
-	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
-		log_warn("WARNING: Physical volume %s not allocatable.", pvname);
-		return 1;
-	}
-
-	if (allocatable_only && is_missing_pv(pvl->pv)) {
-		log_warn("WARNING: Physical volume %s is missing.", pvname);
-		return 1;
-	}
-
-	if (allocatable_only &&
-	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
-		log_warn("WARNING: No free extents on physical volume \"%s\".", pvname);
-		return 1;
-	}
-
-	dm_list_iterate_items(pvl2, r)
-		if (pvl->pv->dev == pvl2->pv->dev) {
-			new_pvl = pvl2;
-			break;
-		}
-
-	if (!new_pvl) {
-		if (!(new_pvl = dm_pool_alloc(mem, sizeof(*new_pvl)))) {
-			log_error("Unable to allocate physical volume list.");
-			return 0;
-		}
-
-		memcpy(new_pvl, pvl, sizeof(*new_pvl));
-
-		if (!(pe_ranges = dm_pool_alloc(mem, sizeof(*pe_ranges)))) {
-			log_error("Allocation of pe_ranges list failed.");
-			return 0;
-		}
-		dm_list_init(pe_ranges);
-		new_pvl->pe_ranges = pe_ranges;
-		dm_list_add(r, &new_pvl->list);
-	}
-
-	/* Determine selected physical extents */
-	if (!_parse_pes(mem, colon, new_pvl->pe_ranges, pv_dev_name(pvl->pv),
-			pvl->pv->pe_count))
-		return_0;
-
-	return 1;
-}
-
-struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
-			    char **argv, int allocatable_only)
-{
-	struct dm_list *r;
-	struct pv_list *pvl;
-	struct dm_list tagsl, arg_pvnames;
-	char *pvname = NULL;
-	char *colon, *at_sign, *tagname;
-	int i;
-
-	/* Build up list of PVs */
-	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
-		log_error("Allocation of list failed.");
-		return NULL;
-	}
-	dm_list_init(r);
-
-	dm_list_init(&tagsl);
-	dm_list_init(&arg_pvnames);
-
-	for (i = 0; i < argc; i++) {
-		dm_unescape_colons_and_at_signs(argv[i], &colon, &at_sign);
-
-		if (at_sign && (at_sign == argv[i])) {
-			tagname = at_sign + 1;
-			if (!validate_tag(tagname)) {
-				log_error("Skipping invalid tag %s.", tagname);
-				continue;
-			}
-			dm_list_iterate_items(pvl, &vg->pvs) {
-				if (str_list_match_item(&pvl->pv->tags,
-							tagname)) {
-					if (!_create_pv_entry(mem, pvl, NULL,
-							      allocatable_only,
-							      r))
-						return_NULL;
-				}
-			}
-			continue;
-		}
-
-		pvname = argv[i];
-
-		if (colon && !(pvname = dm_pool_strndup(mem, pvname,
-					(unsigned) (colon - pvname)))) {
-			log_error("Failed to clone PV name.");
-			return NULL;
-		}
-
-		if (!(pvl = find_pv_in_vg(vg, pvname))) {
-			log_error("Physical Volume \"%s\" not found in "
-				  "Volume Group \"%s\".", pvname, vg->name);
-			return NULL;
-		}
-		if (!_create_pv_entry(mem, pvl, colon, allocatable_only, r))
-			return_NULL;
-	}
-
-	if (dm_list_empty(r))
-		log_error("No specified PVs have space available.");
-
-	return dm_list_empty(r) ? NULL : r;
-}
-
-struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvsl)
-{
-	struct dm_list *r;
-	struct pv_list *pvl, *new_pvl;
-
-	/* Build up list of PVs */
-	if (!(r = dm_pool_alloc(mem, sizeof(*r)))) {
-		log_error("Allocation of list failed.");
-		return NULL;
-	}
-	dm_list_init(r);
-
-	dm_list_iterate_items(pvl, pvsl) {
-		if (!(new_pvl = dm_pool_zalloc(mem, sizeof(*new_pvl)))) {
-			log_error("Unable to allocate physical volume list.");
-			return NULL;
-		}
-
-		memcpy(new_pvl, pvl, sizeof(*new_pvl));
-		dm_list_add(r, &new_pvl->list);
-	}
-
-	return r;
-}
-
 const char _pe_size_may_not_be_negative_msg[] = "Physical extent size may not be negative.";
 
 int vgcreate_params_set_defaults(struct cmd_context *cmd,
diff --git a/tools/toollib.h b/tools/toollib.h
index 9102f55ae..53a5e5b4f 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -182,15 +182,6 @@ void opt_array_to_str(struct cmd_context *cmd, int *opts, int count,
 int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *pp);
 int pvcreate_each_device(struct cmd_context *cmd, struct processing_handle *handle, struct pvcreate_params *pp);
 
-/*
- * Builds a list of pv's from the names in argv.  Used in
- * lvcreate/extend.
- */
-struct dm_list *create_pv_list(struct dm_pool *mem, struct volume_group *vg, int argc,
-			    char **argv, int allocatable_only);
-
-struct dm_list *clone_pv_list(struct dm_pool *mem, struct dm_list *pvs);
-
 int vgcreate_params_set_defaults(struct cmd_context *cmd,
 				 struct vgcreate_params *vp_def,
 				 struct volume_group *vg);



