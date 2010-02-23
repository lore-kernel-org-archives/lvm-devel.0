From: Milan Broz <mbroz@redhat.com>
Date: Tue, 23 Feb 2010 14:46:56 +0100
Subject: [PATCH 2/2] Remove lvs_in_vg_activated_by_uuid_only call.
In-Reply-To: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
References: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
Message-ID: <1266932816-5621-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

THere is no difference from lvs_in_vg_activated now,
convert all users to this call.
---
 lib/activate/activate.c |   16 +---------------
 lib/activate/activate.h |    1 -
 tools/vgrename.c        |    4 ++--
 3 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3c7105b..dcdad73 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -171,10 +171,6 @@ int lvs_in_vg_activated(struct volume_group *vg)
 {
 	return 0;
 }
-int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg)
-{
-	return 0;
-}
 int lvs_in_vg_opened(struct volume_group *vg)
 {
 	return 0;
@@ -627,7 +623,7 @@ static int _lv_suspend_lv(struct logical_volume *lv, int lockfs, int flush_requi
  * These two functions return the number of visible LVs in the state,
  * or -1 on error.
  */
-static int _lvs_in_vg_activated(struct volume_group *vg, unsigned by_uuid_only)
+int lvs_in_vg_activated(struct volume_group *vg)
 {
 	struct lv_list *lvl;
 	int count = 0;
@@ -643,16 +639,6 @@ static int _lvs_in_vg_activated(struct volume_group *vg, unsigned by_uuid_only)
 	return count;
 }
 
-int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg)
-{
-	return _lvs_in_vg_activated(vg, 1);
-}
-
-int lvs_in_vg_activated(struct volume_group *vg)
-{
-	return _lvs_in_vg_activated(vg, 0);
-}
-
 int lvs_in_vg_opened(const struct volume_group *vg)
 {
 	const struct lv_list *lvl;
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index ba70372..32d9a5c 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -91,7 +91,6 @@ int lv_mirror_percent(struct cmd_context *cmd, struct logical_volume *lv,
  * Return number of LVs in the VG that are active.
  */
 int lvs_in_vg_activated(struct volume_group *vg);
-int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
 int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(struct logical_volume *lv);
diff --git a/tools/vgrename.c b/tools/vgrename.c
index faf20bc..a63a626 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -29,7 +29,7 @@ static struct volume_group *vg_rename_old(struct cmd_context *cmd,
 		return_NULL;
 	}
 
-	if (lvs_in_vg_activated_by_uuid_only(vg)) {
+	if (lvs_in_vg_activated(vg)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
 		log_error("Volume group \"%s\" still has active LVs",
 			  vg_name_old);
@@ -161,7 +161,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename.");
 
-		else if (lvs_in_vg_activated_by_uuid_only(vg)) {
+		else if (lvs_in_vg_activated(vg)) {
 			if (!vg_refresh_visible(cmd, vg)) {
 				log_error("Renaming \"%s\" to \"%s\" failed", 
 					old_path, new_path);
-- 
1.7.0


