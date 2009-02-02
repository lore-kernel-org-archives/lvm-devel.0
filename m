From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 10:07:32 -0500
Subject: [PATCH] Rename get_vgs() to get_vgnames() and clarify related error messages.
Message-ID: <1233587252-15191-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

get_vgs() really returns a list of vgnames.  In the future we will use
get_vgs() to return a list of vg structures, similar to get_pvs().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    8 ++++----
 tools/toollib.c                  |    4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index e785383..a1c45ce 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -370,7 +370,7 @@ struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
 struct dm_list *get_pvs(struct cmd_context *cmd);
 
 /* Set full_scan to 1 to re-read every (filtered) device label */
-struct dm_list *get_vgs(struct cmd_context *cmd, int full_scan);
+struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan);
 struct dm_list *get_vgids(struct cmd_context *cmd, int full_scan);
 int scan_vgs_for_pvs(struct cmd_context *cmd);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0130bd3..a2b5f2f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2039,8 +2039,8 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	 *       allowed to do a full scan here any more. */
 
 	// The slow way - full scan required to cope with vgrename
-	if (!(vgnames = get_vgs(cmd, 2))) {
-		log_error("vg_read_by_vgid: get_vgs failed");
+	if (!(vgnames = get_vgnames(cmd, 2))) {
+		log_error("vg_read_by_vgid: get_vgnames failed");
 		return NULL;
 	}
 
@@ -2167,7 +2167,7 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 }
 
 /* May return empty list */
-struct dm_list *get_vgs(struct cmd_context *cmd, int full_scan)
+struct dm_list *get_vgnames(struct cmd_context *cmd, int full_scan)
 {
 	return lvmcache_get_vgnames(cmd, full_scan);
 }
@@ -2201,7 +2201,7 @@ static int _get_pvs(struct cmd_context *cmd, struct dm_list **pvslist)
 
 	/* Get list of VGs */
 	if (!(vgids = get_vgids(cmd, 0))) {
-		log_error("get_pvs: get_vgs failed");
+		log_error("get_pvs: get_vgids failed");
 		return 0;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 84d5108..d8b32a5 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -273,7 +273,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv,
 
 	if (!argc || !dm_list_empty(&tags)) {
 		log_verbose("Finding all logical volumes");
-		if (!(vgnames = get_vgs(cmd, 0)) || dm_list_empty(vgnames)) {
+		if (!(vgnames = get_vgnames(cmd, 0)) || dm_list_empty(vgnames)) {
 			log_error("No volume groups found");
 			return ret_max;
 		}
@@ -713,7 +713,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			if (sigint_caught())
 				return ret_max;
 		}
-		if (!dm_list_empty(&tags) && (vgnames = get_vgs(cmd, 0)) &&
+		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0)) &&
 			   !dm_list_empty(vgnames)) {
 			dm_list_iterate_items(sll, vgnames) {
 				if (!lock_vol(cmd, sll->str, lock_type)) {
-- 
1.5.5.1


