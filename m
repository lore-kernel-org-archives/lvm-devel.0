From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Dec 2015 17:22:20 +0000 (UTC)
Subject: master - cleanup: use try_id_read_format
Message-ID: <20151203172220.A3BAB6067A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20483ead5bbc74b68126dfadec7b5f98f41b3400
Commit:        20483ead5bbc74b68126dfadec7b5f98f41b3400
Parent:        c15c44a4924e07d96cea04672fbcd45c7d8aa7ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 3 15:26:44 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 3 18:00:54 2015 +0100

cleanup: use try_id_read_format

Better then using log_suppress in this case.
---
 tools/toollib.c  |    7 ++-----
 tools/vgrename.c |    4 +---
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3980a88..e03aaf7 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2101,11 +2101,8 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 		 * matches the UUID of a VG.  (--select should generally
 		 * be used to select a VG by uuid instead.)
 		 */
-		if (!found && (cmd->command->flags & ALLOW_UUID_AS_NAME)) {
-			log_suppress(2);
-			arg_is_uuid = id_read_format(&id, sl->str);
-			log_suppress(0);
-		}
+		if (!found && (cmd->command->flags & ALLOW_UUID_AS_NAME))
+			arg_is_uuid = id_read_format_try(&id, sl->str);
 
 		if (!found && arg_is_uuid) {
 			dm_list_iterate_items_safe(vgnl, vgnl2, vgnameids_on_system) {
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 07d992e..9e6beec 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -107,9 +107,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		}
 	}
 
-	log_suppress(2);
-	found_id = id_read_format(&id, vg_name_old);
-	log_suppress(0);
+	found_id = id_read_format_try(&id, vg_name_old);
 
 	if (found_id && (vg_name = lvmcache_vgname_from_vgid(cmd->mem, (char *)id.uuid))) {
 		if (!strcmp(vg_name, vg_name_new)) {


