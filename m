From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  9 Jul 2013 11:36:04 +0000 (UTC)
Subject: master - metadata: cleanup comments and formatting
Message-ID: <20130709113604.9E5DA61177@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aaa9a68b2fc8a25377f4649b89b59a9893179633
Commit:        aaa9a68b2fc8a25377f4649b89b59a9893179633
Parent:        934616d4c759cd1dfe2b359fc83632999daf1ce8
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 9 12:34:48 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 9 12:34:48 2013 +0100

metadata: cleanup comments and formatting

---
 lib/metadata/lv_manip.c   |    5 ++-
 lib/metadata/metadata.c   |   65 +++++++++++++++++++++++++--------------------
 lib/metadata/thin_manip.c |    6 ++--
 liblvm/lvm_base.c         |    4 +-
 4 files changed, 44 insertions(+), 36 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9d67e71..0941964 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -340,8 +340,9 @@ percent_t copy_percent(const struct logical_volume *lv)
 	dm_list_iterate_items(seg, &lv->segments) {
 		denominator += seg->area_len;
 
-		if ((seg_is_raid(seg) || seg_is_mirrored(seg))
-		    && (seg->area_count > 1))
+	/* FIXME Generalise name of 'extents_copied' field */
+		if ((seg_is_raid(seg) || seg_is_mirrored(seg)) &&
+		    (seg->area_count > 1))
 			numerator += seg->extents_copied;
 		else
 			numerator += seg->area_len;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ca6da86..96e1355 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3727,12 +3727,13 @@ static int _get_pvs(struct cmd_context *cmd, int warnings,
 			continue;
 		}
 
-		/* When we are retrieving a list to return toliblvm we need
+		/*
+		 * When we are retrieving a list to return toliblvm we need
 		 * that list to contain VGs that are modifiable as we are using
 		 * the vgmem pool in the vg to provide allocation for liblvm.
 		 * This is a hack to prevent the vg from getting cached as the
-		 * vgid will be NULL.  There is most definitely a better way
-		 * to do this.
+		 * vgid will be NULL.
+		 * FIXME Remove this hack.
 		 */
 		if (!(vg = vg_read_internal(cmd, vgname, (!vgslist) ? vgid : NULL, warnings, &consistent))) {
 			stack;
@@ -3750,28 +3751,33 @@ static int _get_pvs(struct cmd_context *cmd, int warnings,
 					release_vg(vg);
 					return 0;
 				}
-				/* If we are going to release the vg, don't store a pointer to
-				 * it in the pv structure.
+				/* If we are going to release the VG, don't
+				 * store a pointer to it in the PV structure.
 				 */
-				if (!vgslist) {
+				if (!vgslist)
 					pvl_copy->pv->vg = NULL;
-				} else {
-					/* Make sure the vg mode indicates writeable */
-					/* We should rework this function to take a parameter */
-					/* so that we could control this ... */
+				else
+					/*
+					 * Make sure the vg mode indicates
+					 * writeable.
+					 * FIXME Rework function to take a
+					 * parameter to control this
+					 */
 					pvl_copy->pv->vg->open_mode = 'w';
-				}
 				have_pv = 1;
 				dm_list_add(pvslist, &pvl_copy->list);
 			}
 
-		/* In the case of the library we want to preserve the embedded volume
-		 * group as subsequent calls to retrieve data about the pv require it.
+		/*
+		 * In the case of the library we want to preserve the embedded
+		 * volume group as subsequent calls to retrieve data about the
+		 * PV require it.
 		 */
-		if (!vgslist || have_pv == 0) {
+		if (!vgslist || !have_pv)
 			release_vg(vg);
-		} else {
-			/* Add vg to list of vg objects that will be returned
+		else {
+			/*
+			 * Add VG to list of VG objects that will be returned
 			 */
 			vgl_item = dm_pool_alloc(cmd->mem, sizeof(*vgl_item));
 			if (!vgl_item) {
@@ -3786,23 +3792,25 @@ static int _get_pvs(struct cmd_context *cmd, int warnings,
 	}
 	init_pvmove(old_pvmove);
 
-	if (!pvslist) {
+	if (!pvslist)
 		dm_pool_free(cmd->mem, vgids);
-	}
+
 	return 1;
 }
 
-/* Retrieve a list of all physical volumes.
- * @param 	cmd			Command context
- * @param	pvslist		Set to NULL if you want memory for list created,
- * 						else valid memory
- * @param	vgslist		Set to NULL if you need the pv structures to contain
- * 						valid vg pointer.  This is the list of VGs
- * @returns NULL on errors, else pvslist which will equal passes in value if
- * 	supplied.
+/*
+ * Retrieve a list of all physical volumes.
+ * @param 	cmd	Command context
+ * @param	pvslist	Set to NULL if you want memory for list created,
+ * 			else valid memory
+ * @param	vgslist	Set to NULL if you need the pv structures to contain
+ * 			valid vg pointer.  This is the list of VGs
+ * @returns NULL on errors, else pvslist which will equal passed-in value if
+ * supplied.
  */
 struct dm_list *get_pvs_internal(struct cmd_context *cmd,
-					struct dm_list *pvslist, struct dm_list *vgslist)
+				 struct dm_list *pvslist,
+				 struct dm_list *vgslist)
 {
 	struct dm_list *results = pvslist;
 
@@ -3816,9 +3824,8 @@ struct dm_list *get_pvs_internal(struct cmd_context *cmd,
 	}
 
 	if (!_get_pvs(cmd, 1, results, vgslist)) {
-		if (NULL == pvslist) {
+		if (!pvslist)
 			dm_pool_free(cmd->mem, results);
-		}
 		return NULL;
 	}
 	return results;
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index f40fd74..5b1b440 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -79,7 +79,7 @@ int detach_pool_lv(struct lv_segment *seg)
 	int no_update = 0;
 
 	if (!seg->pool_lv || !lv_is_thin_pool(seg->pool_lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not a thin volume",
+		log_error(INTERNAL_ERROR "Cannot detach pool from non-thin LV %s",
 			  seg->lv->name);
 		return 0;
 	}
@@ -154,7 +154,7 @@ int attach_pool_message(struct lv_segment *pool_seg, dm_thin_message_t type,
 	struct lv_thin_message *tmsg;
 
 	if (!seg_is_thin_pool(pool_seg)) {
-		log_error(INTERNAL_ERROR "LV %s is not pool.", pool_seg->lv->name);
+		log_error(INTERNAL_ERROR "Cannot attach message to non-pool LV %s.", pool_seg->lv->name);
 		return 0;
 	}
 
@@ -289,7 +289,7 @@ int pool_is_active(const struct logical_volume *lv)
 	const struct seg_list *sl;
 
 	if (!lv_is_thin_pool(lv)) {
-		log_error(INTERNAL_ERROR "LV %s is not pool.", lv->name);
+		log_error(INTERNAL_ERROR "pool_is_active called with non-pool LV %s.", lv->name);
 		return 0;
 	}
 
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 67ed023..b7603e3 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -67,8 +67,8 @@ lvm_t lvm_init(const char *system_dir)
 	cmd->cmd_line = "liblvm";
 
 	/*
-	 * Turn off writing to stderr etc., not sure if there is a better way
-	 * to do this?
+	 * Turn off writing to stdout/stderr.
+	 * FIXME Fix lib/ to support a non-interactive mode instead.
 	 */
 	log_suppress(1);
 


