From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Oct 2017 20:02:10 -0400
Subject: master - pvmove: simplify name generation
Message-ID: <201711010002.vA102Acp010602@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ba393954296ee9521fffc83fbf4507060f08ffd
Commit:        0ba393954296ee9521fffc83fbf4507060f08ffd
Parent:        bc29785d098ea0d663a07705e07eac27522c164d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 31 20:51:11 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 1 00:55:24 2017 +0100

pvmove: simplify name generation

---
 tools/pvmove.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/tools/pvmove.c b/tools/pvmove.c
index 09ce54b..aa06d02 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -154,8 +154,8 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 					      const char *lv_name,
 					      struct dm_list *trim_list)
 {
-	char *idx, *suffix, *sublv_name;
-	size_t len;
+	char *idx, *suffix;
+	char sublv_name[NAME_LEN];
 	struct logical_volume *sublv;
 	struct dm_list untrim_list, *pvh1, *pvh2;
 	struct pv_list *pvl1, *pvl2;
@@ -172,18 +172,18 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 	if (!(suffix = first_substring(lv_name, "_rimage_", "_rmeta_", NULL)))
 		return 0;
 
-	if (!(idx = strstr(suffix + 1, "_")))
+	if (!(idx = strchr(suffix + 1, '_'))) {
+		log_error("Can't find '_' after suffix %s.", suffix);
 		return 0;
+	}
 	idx++;
 
-	/* + 2 for the longer rimage string */
-	if (!(sublv_name = dm_pool_alloc(lv->vg->cmd->mem, strlen(lv_name + 2))))
-		return_0;
-
 	/* Create the siblings name (e.g. "raidlv_rmeta_N" -> "raidlv_rimage_N" */
-	len = suffix - lv_name;
-	strncpy(sublv_name, lv_name, len);
-	sprintf(sublv_name + len, strstr(suffix, "_rimage_") ? "_rmeta_%s" : "_rimage_%s", idx);
+	if (dm_snprintf(sublv_name, sizeof(sublv_name), "%s_r%s_%s", lv_name,
+			strstr(suffix, "_rimage_") ? "meta" : "image", idx) < 0) {
+		log_error("Raid sublv for name %s too long.", lv_name);
+		return 0;
+	}
 
 	if (!(sublv = find_lv(lv->vg, sublv_name))) {
 		log_error("Can't find sub LV %s?", sublv_name);


