From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:32 +0000 (UTC)
Subject: master - toollib: only interpret vgname arg as uuid for vgrename
Message-ID: <20151202000832.B885B60C91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=61573bd1972702f1066c3df5543acc47e9e35da8
Commit:        61573bd1972702f1066c3df5543acc47e9e35da8
Parent:        166adf0e1fb01f0557a068086a73d9d40f9e5652
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 1 15:50:14 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 15:50:14 2015 -0600

toollib: only interpret vgname arg as uuid for vgrename

In general, --select should be used to specify a VG by UUID,
but vgrename already allows a uuid to be substituted for
the name, so continue to allow it in that case.
---
 tools/commands.h |    2 +-
 tools/toollib.c  |   11 ++++-------
 tools/tools.h    |    2 ++
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 5770bf3..8c5162b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1323,7 +1323,7 @@ xx(vgremove,
 
 xx(vgrename,
    "Rename a volume group",
-   0,
+   ALLOW_UUID_AS_NAME,
    "vgrename\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--commandprofile ProfileName]\n"
diff --git a/tools/toollib.c b/tools/toollib.c
index 8e4db5e..3980a88 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2081,7 +2081,7 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 	struct dm_str_list *sl, *sl2;
 	struct vgnameid_list *vgnl, *vgnl2;
 	struct id id;
-	int arg_is_uuid;
+	int arg_is_uuid = 0;
 	int found;
 
 	dm_list_iterate_items_safe(sl, sl2, arg_vgnames) {
@@ -2098,13 +2098,10 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 
 		/*
 		 * If the VG name arg looks like a UUID, then check if it
-		 * matches the UUID of a VG.
-		 *
-		 * FIXME: Do we want to allow vgname args to be interpretted
-		 * as uuids for all commands or only some (e.g. vgrename)?
-		 * If only some, then use a cmd flag to enable this.
+		 * matches the UUID of a VG.  (--select should generally
+		 * be used to select a VG by uuid instead.)
 		 */
-		if (!found) {
+		if (!found && (cmd->command->flags & ALLOW_UUID_AS_NAME)) {
 			log_suppress(2);
 			arg_is_uuid = id_read_format(&id, sl->str);
 			log_suppress(0);
diff --git a/tools/tools.h b/tools/tools.h
index 27061fc..010fbf4 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -99,6 +99,8 @@ struct arg_value_group_list {
 #define ALL_VGS_IS_DEFAULT	0x00000004
 /* Process all devices with --all if none are specified on the command line. */
 #define ENABLE_ALL_DEVS		0x00000008	
+/* Command may try to interpret a vgname arg as a uuid. */
+#define ALLOW_UUID_AS_NAME	0x00000010
 /* Command needs a shared lock on a VG; it only reads the VG. */
 #define LOCKD_VG_SH		0x00000020
 /* Command does not process any metadata. */


