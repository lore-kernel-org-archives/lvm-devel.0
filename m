From: agk@sourceware.org <agk@sourceware.org>
Date: 11 May 2012 15:26:31 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120511152631.12429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-11 15:26:30

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Refactor _has_matching_pv_tag to provide a fn that takes PV structs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.375&r2=1.376

--- LVM2/lib/metadata/lv_manip.c	2012/05/09 12:12:21	1.375
+++ LVM2/lib/metadata/lv_manip.c	2012/05/11 15:26:30	1.376
@@ -1248,13 +1248,13 @@
  * Does PV area have a tag listed in allocation/cling_tag_list that 
  * matches a tag of the PV of the existing segment?
  */
-static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
+static int _pvs_have_matching_tag(const struct dm_config_node *cling_tag_list_cn, struct physical_volume *pv1, struct physical_volume *pv2)
 {
 	const struct dm_config_value *cv;
 	const char *str;
 	const char *tag_matched;
 
-	for (cv = pvmatch->cling_tag_list_cn->v; cv; cv = cv->next) {
+	for (cv = cling_tag_list_cn->v; cv; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
 			log_error("Ignoring invalid string in config file entry "
 				  "allocation/cling_tag_list");
@@ -1283,21 +1283,21 @@
 
 		/* Wildcard matches any tag against any tag. */
 		if (!strcmp(str, "*")) {
-			if (!str_list_match_list(&pvseg->pv->tags, &pva->map->pv->tags, &tag_matched))
+			if (!str_list_match_list(&pv1->tags, &pv2->tags, &tag_matched))
 				continue;
 			else {
 				log_debug("Matched allocation PV tag %s on existing %s with free space on %s.",
-					  tag_matched, pv_dev_name(pvseg->pv), pv_dev_name(pva->map->pv));
+					  tag_matched, pv_dev_name(pv1), pv_dev_name(pv2));
 				return 1;
 			}
 		}
 
-		if (!str_list_match_item(&pvseg->pv->tags, str) ||
-		    !str_list_match_item(&pva->map->pv->tags, str))
+		if (!str_list_match_item(&pv1->tags, str) ||
+		    !str_list_match_item(&pv2->tags, str))
 			continue;
 		else {
 			log_debug("Matched allocation PV tag %s on existing %s with free space on %s.",
-				  str, pv_dev_name(pvseg->pv), pv_dev_name(pva->map->pv));
+				  str, pv_dev_name(pv1), pv_dev_name(pv2));
 			return 1;
 		}
 	}
@@ -1305,6 +1305,11 @@
 	return 0;
 }
 
+static int _has_matching_pv_tag(struct pv_match *pvmatch, struct pv_segment *pvseg, struct pv_area *pva)
+{
+	return _pvs_have_matching_tag(pvmatch->cling_tag_list_cn, pvseg->pv, pva->map->pv);
+}
+
 /*
  * Is PV area contiguous to PV segment?
  */


