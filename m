From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:23 -0400
Subject: master - cachevol: rename converted LV to _cvol
Message-ID: <201910141322.x9EDMNAa018796@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8a8e6ebba2521da596e9e85fe2799e336640ace3
Commit:        8a8e6ebba2521da596e9e85fe2799e336640ace3
Parent:        f6d171ffe33455ab48e142820aa74be901e8aee9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 12 23:37:17 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:15:12 2019 +0200

cachevol: rename converted LV to _cvol

When converting existing public LV to internally used
'CacheVol' LV - rename LV to LV_cvol.

When splitting CacheVol, remove _cvol suffix.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   29 +++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6405686..6d1700a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Rename LV converted to cachevol to use _cvol suffix.
   Use normal LVs for wiping of cachevols.
   Reload cleanered cache DM only with cleaner policy.
   Fix cmd return when zering of cachevol fails.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 885380c..14663e8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1840,6 +1840,8 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 				   struct logical_volume *lv,
 				   struct logical_volume *lv_fast)
 {
+	char cvol_name[NAME_LEN];
+	char *c;
 	struct lv_segment *cache_seg = first_seg(lv);
 	int cache_mode = cache_seg->cache_mode;
 	int noflush = 0;
@@ -1879,6 +1881,25 @@ static int _lvconvert_split_and_keep_cachevol(struct cmd_context *cmd,
 	if (!lv_detach_cache_vol(lv, noflush))
 		return_0;
 
+	/* Cut off suffix _cvol */
+	if (!dm_strncpy(cvol_name, lv_fast->name, sizeof(cvol_name)) ||
+	    !(c = strstr(cvol_name, "_cvol"))) {
+		/* likely older instance of metadata */
+		log_debug("LV %s has no suffix for cachevol (skipping rename).",
+			  display_lvname(lv_fast));
+	} else {
+		*c = 0;
+		/* If the name is in use, generate new lvol%d */
+		if (lv_name_is_used_in_vg(lv->vg, cvol_name, NULL) &&
+		    !generate_lv_name(lv->vg, "lvol%d", cvol_name, sizeof(cvol_name))) {
+			log_error("Failed to generate unique name for unused logical volume.");
+			return 0;
+		}
+
+		if (!lv_rename_update(cmd, lv_fast, cvol_name, 0))
+			return_0;
+	}
+
 	if (!vg_write(lv->vg) || !vg_commit(lv->vg))
 		return_0;
 
@@ -4193,6 +4214,7 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *cachevol_lv;
 	const char *cachevol_name;
+	char cvol_name[NAME_LEN];
 
 	if (!(cachevol_name = arg_str_value(cmd, cachevol_ARG, NULL)))
 		goto_out;
@@ -4238,6 +4260,13 @@ static int _lvconvert_cachevol_attach_single(struct cmd_context *cmd,
 		goto_out;
 
 	/* Attach the cache to the main LV. */
+	if (dm_snprintf(cvol_name, sizeof(cvol_name), "%s_cvol", cachevol_lv->name) < 0) {
+		log_error("Can't prepare new metadata name for %s.", display_lvname(cachevol_lv));
+		return 0;
+	}
+	if (!lv_rename_update(cmd, cachevol_lv, cvol_name, 0))
+		return_0;
+
 	cachevol_lv->status |= LV_CACHE_VOL;
 	if (!_cache_vol_attach(cmd, lv, cachevol_lv))
 		goto_out;


