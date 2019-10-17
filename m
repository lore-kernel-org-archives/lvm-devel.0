From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 17 Oct 2019 07:05:05 -0400
Subject: master - cachevol: move cvol rename
Message-ID: <201910171105.x9HB55er023614@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a255385e3a5e3668eb0a4772cd867a3a7394285b
Commit:        a255385e3a5e3668eb0a4772cd867a3a7394285b
Parent:        dab4a2c893ef48636809b75b2ee225e195073fe0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 12:10:47 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 13:03:50 2019 +0200

cachevol: move cvol rename

Move rename of CVOL after archive().
---
 tools/lvconvert.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 48ff8e1..a21f965 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3453,6 +3453,7 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 			        struct logical_volume *lv,
 			        struct logical_volume *lv_fast)
 {
+	char cvol_name[NAME_LEN];
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *cache_lv;
 	uint32_t chunk_size = 0;
@@ -3475,6 +3476,18 @@ static int _cache_vol_attach(struct cmd_context *cmd,
 	if (!archive(vg))
 		goto_out;
 
+	/*
+	 * The lvm tradition is to rename an LV with a special role-specific
+	 * suffix when it becomes hidden.  Here the _cvol suffix is added to
+	 * the fast LV name.  When the cache is detached, it's renamed back.
+	 */
+	if (dm_snprintf(cvol_name, sizeof(cvol_name), "%s_cvol", lv_fast->name) < 0) {
+		log_error("Can't prepare new cachevol name for %s.", display_lvname(lv_fast));
+		goto out;
+	}
+	if (!lv_rename_update(cmd, lv_fast, cvol_name, 0))
+		goto_out;
+
 	lv_fast->status |= LV_CACHE_VOL; /* Mark as cachevol LV */
 
 	/*
@@ -4216,7 +4229,6 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *cachevol_lv;
 	const char *cachevol_name;
-	char cvol_name[NAME_LEN];
 
 	if (!(cachevol_name = arg_str_value(cmd, cachevol_ARG, NULL)))
 		goto_out;
@@ -4261,18 +4273,6 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	if (_raid_split_image_conversion(lv))
 		goto_out;
 
-	/*
-	 * The lvm tradition is to rename an LV with a special role-specific
-	 * suffix when it becomes hidden.  Here the _cvol suffix is added to
-	 * the fast LV name.  When the cache is detached, it's renamed back.
-	 */
-	if (dm_snprintf(cvol_name, sizeof(cvol_name), "%s_cvol", cachevol_lv->name) < 0) {
-		log_error("Can't prepare new metadata name for %s.", display_lvname(cachevol_lv));
-		return 0;
-	}
-	if (!lv_rename_update(cmd, cachevol_lv, cvol_name, 0))
-		return_0;
-
 	/* Attach the cache to the main LV. */
 
 	if (!_cache_vol_attach(cmd, lv, cachevol_lv))


