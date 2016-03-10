From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Mar 2016 17:40:07 +0000 (UTC)
Subject: master - lvconvert: improve vg parameter parsing
Message-ID: <20160310174007.2C80060804@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=70cbd8f1a5cc6abb418a90529bc12a2813806f13
Commit:        70cbd8f1a5cc6abb418a90529bc12a2813806f13
Parent:        5c415afd852b6d39021f97f63401a37e6408bf70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 8 10:13:38 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 10 18:38:53 2016 +0100

lvconvert: improve vg parameter parsing

Commit abd9618dd8b77ca1974074ae76fa6a08f1a687d9 tried to improve
parsing of vg name from logical path - but still missed couple
corner cases.

This patch further improves the logic and reuses
validate_lvname_param() for parsing of lv_name.

Also explicitly checks for LVM_VG_NAME in the right case.

So now also properly parses cases like:
  'lvconvert --repairt vg/'
and will provide correct error message.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   25 ++++++++++---------------
 2 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5b28bb..eab40b1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.146 - 
 =================================
+  Another attempt to improve VG name parsing for lvconvert (2.02.144).
   Use new cache status info and skip flushing for failed cache.
   Support --uncache with missing PVs.
   Tidy report field names, headings and widths.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2b5080f..dc6cb48 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -115,9 +115,6 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 				  struct cmd_context *cmd,
 				  int *pargc, char ***pargv)
 {
-	char *ptr;
-	const char *vg_name = NULL;
-
 	if (lp->merge) {
 		if (!*pargc) {
 			log_error("Please specify a logical volume path.");
@@ -174,26 +171,24 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	if (!validate_restricted_lvname_param(cmd, &lp->vg_name, &lp->lv_split_name))
 		return_0;
 
-	if ((vg_name = extract_vgname(cmd, lp->lv_name_full)) &&
-	    lp->vg_name && strcmp(vg_name, lp->vg_name)) {
-		log_error("Please use a single volume group name "
-			  "(\"%s\" or \"%s\")", vg_name, lp->vg_name);
-		return 0;
+	if (!lp->vg_name && !strchr(lp->lv_name_full, '/')) {
+		/* Check for $LVM_VG_NAME */
+		if (!(lp->vg_name = extract_vgname(cmd, NULL))) {
+			log_error("Please specify a logical volume path.");
+			return 0;
+		}
 	}
 
-	if (!lp->vg_name)
-		lp->vg_name = vg_name;
+	if (!validate_lvname_param(cmd, &lp->vg_name, &lp->lv_name_full))
+		return_0;
+
+	lp->lv_name = lp->lv_name_full;
 
 	if (!validate_name(lp->vg_name)) {
 		log_error("Please provide a valid volume group name");
 		return 0;
 	}
 
-	if ((ptr = strrchr(lp->lv_name_full, '/')))
-		lp->lv_name = ptr + 1;
-	else
-		lp->lv_name = lp->lv_name_full;
-
 	if (!lp->merge_mirror &&
 	    !lp->repair &&
 	    !arg_count(cmd, splitmirrors_ARG) &&


