From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:39 -0500
Subject: master - pvmove: fix _remove_sibling_pvs_from_trim_list
Message-ID: <201801171346.w0HDkdHo029985@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c6fb63041cd5c1fb899cc468d0a5cf23a01abbe
Commit:        7c6fb63041cd5c1fb899cc468d0a5cf23a01abbe
Parent:        e86910b052ef50dfdaad104d17bda679f698e31f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 11 13:21:08 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:44:31 2018 +0100

pvmove: fix _remove_sibling_pvs_from_trim_list

Fix the function to really check it sibling raid image LV.
For LV_rmeta_0  check for   LV_rimage_0   instead of
LV_rmeta_0rimage_0.
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |   16 +++++++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index efaa5b3..00334b5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Fix trimming sibling PVs when doing a pvmove of raid subLVs.
   Preserve exclusive activation during thin snaphost merge.
   Suppress some repeated reads of the same disk data at the device layer.
   Avoid exceeding array bounds in allocation tag processing.
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 7bf1713..39cf25f 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -145,6 +145,7 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 					      struct dm_list *trim_list)
 {
 	char *idx, *suffix;
+	const char *sibling;
 	char sublv_name[NAME_LEN];
 	struct logical_volume *sublv;
 	struct dm_list untrim_list, *pvh1, *pvh2;
@@ -159,7 +160,16 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 
 	dm_list_init(&untrim_list);
 
-	if (!(suffix = first_substring(lv_name, "_rimage_", "_rmeta_", NULL))) {
+	if (!dm_strncpy(sublv_name, lv_name, sizeof(sublv_name))) {
+		log_error(INTERNAL_ERROR "LV name %s is too long.", lv_name);
+		return 0;
+	}
+
+	if ((suffix = strstr(sublv_name, "_rimage_")))
+		sibling = "meta";
+	else if ((suffix = strstr(sublv_name, "_rmeta_")))
+		sibling = "image";
+	else {
 		log_error("Can't find rimage or rmeta suffix.");
 		return 0;
 	}
@@ -171,8 +181,8 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 	idx++;
 
 	/* Create the siblings name (e.g. "raidlv_rmeta_N" -> "raidlv_rimage_N" */
-	if (dm_snprintf(sublv_name, sizeof(sublv_name), "%s_r%s_%s", lv_name,
-			strstr(suffix, "_rimage_") ? "meta" : "image", idx) < 0) {
+	if (dm_snprintf(suffix + 2, sizeof(sublv_name) - 2 - (suffix - sublv_name),
+			"%s_%s", sibling, idx) < 0) {
 		log_error("Raid sublv for name %s too long.", lv_name);
 		return 0;
 	}


