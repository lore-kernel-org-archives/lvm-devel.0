From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  2 Dec 2015 00:08:30 +0000 (UTC)
Subject: master - toollib: allow VG UUID to be used in place of VG name
Message-ID: <20151202000830.A799A60C91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=166adf0e1fb01f0557a068086a73d9d40f9e5652
Commit:        166adf0e1fb01f0557a068086a73d9d40f9e5652
Parent:        67763a9bec03415996903a97916b234252fb150d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 1 12:00:57 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 12:08:24 2015 -0600

toollib: allow VG UUID to be used in place of VG name

If the VG arg from the command line does not match the
name of any known VGs, then check if the arg looks like
a UUID.  If it's a valid UUID, then compare it to the
UUID of known VGs.  If it matches the UUID of a known VG,
then process that VG.
---
 tools/toollib.c |   39 +++++++++++++++++++++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index e49356f..8e4db5e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2077,8 +2077,11 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 				   struct dm_list *vgnameids_on_system,
 				   struct dm_list *vgnameids_to_process)
 {
+	char uuid[64] __attribute__((aligned(8)));
 	struct dm_str_list *sl, *sl2;
 	struct vgnameid_list *vgnl, *vgnl2;
+	struct id id;
+	int arg_is_uuid;
 	int found;
 
 	dm_list_iterate_items_safe(sl, sl2, arg_vgnames) {
@@ -2092,6 +2095,42 @@ static void _choose_vgs_to_process(struct cmd_context *cmd,
 			found = 1;
 			break;
 		}
+
+		/*
+		 * If the VG name arg looks like a UUID, then check if it
+		 * matches the UUID of a VG.
+		 *
+		 * FIXME: Do we want to allow vgname args to be interpretted
+		 * as uuids for all commands or only some (e.g. vgrename)?
+		 * If only some, then use a cmd flag to enable this.
+		 */
+		if (!found) {
+			log_suppress(2);
+			arg_is_uuid = id_read_format(&id, sl->str);
+			log_suppress(0);
+		}
+
+		if (!found && arg_is_uuid) {
+			dm_list_iterate_items_safe(vgnl, vgnl2, vgnameids_on_system) {
+				if (!(id_write_format((const struct id*)vgnl->vgid, uuid, sizeof(uuid))))
+					continue;
+
+				if (strcmp(sl->str, uuid))
+					continue;
+
+				log_print("Processing VG %s because of matching UUID %s",
+					  vgnl->vg_name, uuid);
+
+				dm_list_del(&vgnl->list);
+				dm_list_add(vgnameids_to_process, &vgnl->list);
+
+				/* Make the arg_vgnames entry use the actual VG name. */
+				sl->str = dm_pool_strdup(cmd->mem, vgnl->vg_name);
+
+				found = 1;
+				break;
+			}
+		}
 		
 		/*
 		 * If the name arg was not found in the list of all VGs, then


