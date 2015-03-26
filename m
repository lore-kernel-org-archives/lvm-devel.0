From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 26 Mar 2015 19:46:07 +0000 (UTC)
Subject: master - alloc: Only report cling tag errors once.
Message-ID: <20150326194607.F0D036024D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9d74ba3d1601e55da48e34a3a9d7587d0ec3fe4
Commit:        f9d74ba3d1601e55da48e34a3a9d7587d0ec3fe4
Parent:        4b1219ee876b5a27e9fa08a1153632dda0f8efd1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 26 19:43:51 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 26 19:43:51 2015 +0000

alloc: Only report cling tag errors once.

---
 lib/metadata/lv_manip.c |   46 ++++++++++++++++++++++++++++++++++++----------
 1 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2b6855a..67f5f91 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1976,7 +1976,10 @@ static int _is_same_pv(struct pv_match *pvmatch __attribute((unused)), struct pv
  * Does PV area have a tag listed in allocation/cling_tag_list that 
  * matches a tag of the PV of the existing segment?
  */
-static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn, struct physical_volume *pv1, struct physical_volume *pv2)
+static int _match_pv_tags(const struct dm_config_node *cling_tag_list_cn,
+			  struct physical_volume *pv1,
+			  struct physical_volume *pv2,
+			  unsigned validate_only)
 {
 	const struct dm_config_value *cv;
 	const char *str;
@@ -1984,31 +1987,38 @@ static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn
 
 	for (cv = cling_tag_list_cn->v; cv; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
-			log_error("Ignoring invalid string in config file entry "
-				  "allocation/cling_tag_list");
+			if (validate_only)
+				log_warn("WARNING: Ignoring invalid string in config file entry "
+					 "allocation/cling_tag_list");
 			continue;
 		}
 		str = cv->v.str;
 		if (!*str) {
-			log_error("Ignoring empty string in config file entry "
-				  "allocation/cling_tag_list");
+			if (validate_only)
+				log_warn("WARNING: Ignoring empty string in config file entry "
+					 "allocation/cling_tag_list");
 			continue;
 		}
 
 		if (*str != '@') {
-			log_error("Ignoring string not starting with @ in config file entry "
-				  "allocation/cling_tag_list: %s", str);
+			if (validate_only)
+				log_warn("WARNING: Ignoring string not starting with @ in config file entry "
+					 "allocation/cling_tag_list: %s", str);
 			continue;
 		}
 
 		str++;
 
 		if (!*str) {
-			log_error("Ignoring empty tag in config file entry "
-				  "allocation/cling_tag_list");
+			if (validate_only)
+				log_warn("WARNING: Ignoring empty tag in config file entry "
+					 "allocation/cling_tag_list");
 			continue;
 		}
 
+		if (validate_only)
+			continue;
+
 		/* Wildcard matches any tag against any tag. */
 		if (!strcmp(str, "*")) {
 			if (!str_list_match_list(&pv1->tags, &pv2->tags, &tag_matched))
@@ -2033,6 +2043,21 @@ static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn
 	return 0;
 }
 
+static int _validate_tag_list(const struct dm_config_node *cling_tag_list_cn)
+{
+	return _match_pv_tags(cling_tag_list_cn, NULL, NULL, 1);
+}
+
+/*
+ * Does PV area have a tag listed in allocation/cling_tag_list that 
+ * matches a tag of the PV of the existing segment?
+ */
+static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn,
+				  struct physical_volume *pv1, struct physical_volume *pv2)
+{
+	return _match_pv_tags(cling_tag_list_cn, pv1, pv2, 0);
+}
+
 static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
 {
 	return _pvs_have_matching_tag(pvmatch->cling_tag_list_cn, pvseg->pv, pva->map->pv);
@@ -3043,7 +3068,8 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	ah->parallel_areas = parallel_areas;
 
-	ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG, NULL);
+	if ((ah->cling_tag_list_cn = find_config_tree_node(cmd, allocation_cling_tag_list_CFG, NULL)))
+		(void) _validate_tag_list(ah->cling_tag_list_cn);
 
 	ah->maximise_cling = find_config_tree_bool(cmd, allocation_maximise_cling_CFG, NULL);
 


