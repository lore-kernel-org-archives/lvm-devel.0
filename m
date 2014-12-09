From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Dec 2014 09:43:14 +0000 (UTC)
Subject: master - libdm: report: fix incorrect memory use while using --select with --unbuffered for reporting
Message-ID: <20141209094314.D782660EA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f94f8463b0d3dddaa0e429123aba673d106f783e
Commit:        f94f8463b0d3dddaa0e429123aba673d106f783e
Parent:        4c62215bd178c17d0776448bdc99740180c85402
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 9 10:36:27 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 9 10:41:55 2014 +0100

libdm: report: fix incorrect memory use while using --select with --unbuffered for reporting

Under certain circumstances, the selection code can segfault:

$ vgs --select 'pv_name=~/dev/sda' --unbuffered vg0
  VG   #PV #LV #SN Attr   VSize   VFree
  vg0    6   3   0 wz--n- 744.00m 588.00m
Segmentation fault (core dumped)

The problem here is the use of --ubuffered together with regex used in
selection criteria. If the report output is not buffered, each row is
discarded as soon as it is reported. The bug is in the use of report
handle's memory - in the example above, what happens is:

  1) report handle is initialized together with its memory pool

  2) selection tree is initialized from selection criteria string
     (using the report handle's memory pool!)

    2a) this also means the regex is initialized from report handle's mem pool

  3) the object (row) is reported

    3a) any memory needed for output is intialized out of report handle's mem pool
    3b) selection criteria matching is executed - if the regex is checked the
        very first time (for the very first row reported), some more memory
        allocation happens as regex allocates internal structures "on-demand",
        it's allocating from report handle's mem pool (see also step 2a)

  4) the report output is executed

  5) the object (row) is discarded, meaning discarding all the mem pool
     memory used since step 3.

Now, with step 5) we have discarded the regex internal structures from step 3b.
When we execute reporting for another object (row), we're using the same
selection criteria (step 3b), but tihs is second time we're using the regex
and as such, it's already initialized completely. But the regex is missing the
internal structures now as they got discarded in step 5) from previous
object (row) reporting (because we're using "unbuffered" reporting).

To resolve this issue and to prevent any similar future issues where each
object/row memory is discarded after output (the unbuffered reporting) while
selection tree is global for all the object/rows, use separate memory pool
for report's selection.

This patch replaces "struct selection_node *selection_root" in struct
dm_report with new struct selection which contains both "selection_root"
and "mem" for separate mem pool used for selection.

We can change struct dm_report this way as it is not exposed via libdevmapper.

(This patch will have even more meaning for upcoming patches where selection
is used even for non-reporting commands where "internal" reporting and
selection criteria matching happens and where the internal reporting is
not buffered.)
---
 WHATS_NEW            |    1 +
 libdm/libdm-report.c |   49 ++++++++++++++++++++++++++++++++-----------------
 2 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9201f36..ff06b7b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Fix segfault while using --select with regex and --unbuffered for reporting.
   Fix automatic use of configure --enable-udev-systemd-background-jobs.
   Correctly rename active split LV with -splitmirrors for raid1.
   Add report/compact_output to lvm.conf to enable/disable compact report output.
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6d36c1e..e3c3d2f 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -26,6 +26,11 @@
 #define RH_HEADINGS_PRINTED	0x00000200
 #define RH_ALREADY_REPORTED	0x00000400
 
+struct selection {
+	struct dm_pool *mem;
+	struct selection_node *selection_root;
+};
+
 struct dm_report {
 	struct dm_pool *mem;
 
@@ -52,7 +57,9 @@ struct dm_report {
 	/* To store caller private data */
 	void *private;
 
-	struct selection_node *selection_root;
+	/* Selection handle */
+	struct selection *selection;
+
 	/* Null-terminated array of reserved values */
 	const struct dm_report_reserved_value *reserved_values;
 };
@@ -1193,6 +1200,8 @@ struct dm_report *dm_report_init(uint32_t *report_types,
 
 void dm_report_free(struct dm_report *rh)
 {
+	if (rh->selection)
+		dm_pool_destroy(rh->selection->mem);
 	dm_pool_destroy(rh->mem);
 	dm_free(rh);
 }
@@ -1560,10 +1569,10 @@ static int _check_selection(struct dm_report *rh, struct selection_node *sn,
 
 static int _check_report_selection(struct dm_report *rh, struct dm_list *fields)
 {
-	if (!rh->selection_root)
+	if (!rh->selection)
 		return 1;
 
-	return _check_selection(rh, rh->selection_root, fields);
+	return _check_selection(rh, rh->selection->selection_root, fields);
 }
 
 int dm_report_object(struct dm_report *rh, void *object)
@@ -2410,7 +2419,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 	}
 
 	/* set up selection */
-	if (!(fs = dm_pool_zalloc(rh->mem, sizeof(struct field_selection)))) {
+	if (!(fs = dm_pool_zalloc(rh->selection->mem, sizeof(struct field_selection)))) {
 		log_error("dm_report: struct field_selection "
 			  "allocation failed for selection field %s", field_id);
 		return NULL;
@@ -2429,7 +2438,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		memcpy(s, v, len);
 		s[len] = '\0';
 
-		fs->v.r = dm_regex_create(rh->mem, (const char **) &s, 1);
+		fs->v.r = dm_regex_create(rh->selection->mem, (const char **) &s, 1);
 		dm_free(s);
 		if (!fs->v.r) {
 			log_error("dm_report: failed to create regex "
@@ -2438,7 +2447,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 		}
 	} else {
 		/* STRING, NUMBER, SIZE or STRING_LIST */
-		if (!(s = dm_pool_alloc(rh->mem, len + 1))) {
+		if (!(s = dm_pool_alloc(rh->selection->mem, len + 1))) {
 			log_error("dm_report: dm_pool_alloc failed to store "
 				  "value for selection field %s", field_id);
 			goto error;
@@ -2450,7 +2459,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 			case DM_REPORT_FIELD_TYPE_STRING:
 				if (reserved) {
 					fs->v.s = (const char *) _get_reserved_value(reserved);
-					dm_pool_free(rh->mem, s);
+					dm_pool_free(rh->selection->mem, s);
 				} else {
 					fs->v.s = s;
 					if (_check_value_is_reserved(rh, DM_REPORT_FIELD_TYPE_STRING, fs->v.s)) {
@@ -2473,7 +2482,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						goto error;
 					}
 				}
-				dm_pool_free(rh->mem, s);
+				dm_pool_free(rh->selection->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_SIZE:
 				if (reserved)
@@ -2492,7 +2501,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 						goto error;
 					}
 				}
-				dm_pool_free(rh->mem, s);
+				dm_pool_free(rh->selection->mem, s);
 				break;
 			case DM_REPORT_FIELD_TYPE_PERCENT:
 				if (reserved)
@@ -2528,7 +2537,7 @@ static struct field_selection *_create_field_selection(struct dm_report *rh,
 
 	return fs;
 error:
-	dm_pool_free(rh->mem, fs);
+	dm_pool_free(rh->selection->mem, fs);
 	return NULL;
 }
 
@@ -2730,7 +2739,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 			custom = NULL;
 		if (!(last = _tok_value(rh, ft, field_num, implicit,
 					last, &vs, &ve, &flags,
-					&reserved, rh->mem, custom)))
+					&reserved, rh->selection->mem, custom)))
 			goto_bad;
 	}
 
@@ -2741,7 +2750,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 		return_NULL;
 
 	/* create selection node */
-	if (!(sn = _alloc_selection_node(rh->mem, SEL_ITEM)))
+	if (!(sn = _alloc_selection_node(rh->selection->mem, SEL_ITEM)))
 		return_NULL;
 
 	/* add selection to selection node */
@@ -2828,7 +2837,7 @@ static struct selection_node *_parse_and_ex(struct dm_report *rh,
 	}
 
 	if (!and_sn) {
-		if (!(and_sn = _alloc_selection_node(rh->mem, SEL_AND)))
+		if (!(and_sn = _alloc_selection_node(rh->selection->mem, SEL_AND)))
 			goto error;
 	}
 	dm_list_add(&and_sn->selection.set, &n->list);
@@ -2860,7 +2869,7 @@ static struct selection_node *_parse_or_ex(struct dm_report *rh,
 	}
 
 	if (!or_sn) {
-		if (!(or_sn = _alloc_selection_node(rh->mem, SEL_OR)))
+		if (!(or_sn = _alloc_selection_node(rh->selection->mem, SEL_OR)))
 			goto error;
 	}
 	dm_list_add(&or_sn->selection.set, &n->list);
@@ -2893,7 +2902,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		return NULL;
 
 	if (!selection || !selection[0]) {
-		rh->selection_root = NULL;
+		rh->selection = NULL;
 		return rh;
 	}
 
@@ -2914,7 +2923,13 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 		return rh;
 	}
 
-	if (!(root = _alloc_selection_node(rh->mem, SEL_OR)))
+	if (!(rh->selection = dm_pool_zalloc(rh->mem, sizeof(struct selection))) ||
+	    !(rh->selection->mem = dm_pool_create("report selection", 10 * 1024))) {
+		log_error("Failed to allocate report selection structure.");
+		goto bad;
+	}
+
+	if (!(root = _alloc_selection_node(rh->selection->mem, SEL_OR)))
 		goto_bad;
 
 	if (!_parse_or_ex(rh, selection, &fin, root))
@@ -2930,7 +2945,7 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 
 	_dm_report_init_update_types(rh, report_types);
 
-	rh->selection_root = root;
+	rh->selection->selection_root = root;
 	return rh;
 bad:
 	dm_report_free(rh);


