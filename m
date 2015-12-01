From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  1 Dec 2015 15:12:11 +0000 (UTC)
Subject: master - process_each: resolve duplicate VG names
Message-ID: <20151201151211.0CB1E60F67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa4932674aa6c7e1f2526781caaa98a1920fd72a
Commit:        aa4932674aa6c7e1f2526781caaa98a1920fd72a
Parent:        4ff2583dc5ffb87ad4265d7f0d9063c482cbc3a7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 30 12:11:01 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 1 09:09:55 2015 -0600

process_each: resolve duplicate VG names

If two different VGs with the same name exist on the system,
a command that just specifies that ambiguous name will fail
with a new error:

$ vgs -o name,uuid
  ...
  foo qyUS65-vn32-TuKs-a8yF-wfeQ-7DkF-Fds0uf
  foo vfhKCP-mpc7-KLLL-Uh08-4xPG-zLNR-4cnxJX

$ lvs foo
  Multiple VGs found with the same name: foo
  Use the --select option with VG UUID (vg_uuid).

$ vgremove foo
  Multiple VGs found with the same name: foo
  Use the --select option with VG UUID (vg_uuid).

$ lvs -S vg_uuid=qyUS65-vn32-TuKs-a8yF-wfeQ-7DkF-Fds0uf
  lv1 foo ...

This is implemented for process_each_vg/lv, and works
with or without lvmetad.  It does not work for commands
that do not use process_each.

This change includes one exception to the behavior shown
above.  If one of the VGs is foreign, and the other is not,
then the command assumes that the intended VG is the local
one and uses it.
---
 tools/toollib.c |   93 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 889bbb0..ce1cdda 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2026,6 +2026,77 @@ static int _copy_str_to_vgnameid_list(struct cmd_context *cmd, struct dm_list *s
 }
 
 /*
+ * Check if a command line VG name is ambiguous, i.e. there are multiple VGs on
+ * the system that have the given name.  If *one* VG with the given name is
+ * local and the rest are foreign, then use the local VG (removing foreign VGs
+ * with the same name from the vgnameids_on_system list).  If multiple VGs with
+ * the given name are local, we don't know which VG is intended, so remove the
+ * ambiguous name from the list of args.
+ */
+static int _resolve_duplicate_vgnames(struct cmd_context *cmd,
+				      struct dm_list *arg_vgnames,
+				      struct dm_list *vgnameids_on_system)
+{
+	struct dm_str_list *sl, *sl2;
+	struct vgnameid_list *vgnl, *vgnl2;
+	char uuid[64] __attribute__((aligned(8)));
+	int found;
+	int ret = ECMD_PROCESSED;
+
+	dm_list_iterate_items_safe(sl, sl2, arg_vgnames) {
+		found = 0;
+		dm_list_iterate_items(vgnl, vgnameids_on_system) {
+			if (strcmp(sl->str, vgnl->vg_name))
+				continue;
+			found++;
+		}
+
+		if (found < 2)
+			continue;
+
+		/*
+		 * More than one VG match the given name.
+		 * If only one is local, use that one.
+		 */
+
+		found = 0;
+		dm_list_iterate_items_safe(vgnl, vgnl2, vgnameids_on_system) {
+			if (strcmp(sl->str, vgnl->vg_name))
+				continue;
+
+			/*
+			 * Without lvmetad, a label scan has already populated
+			 * lvmcache vginfo with this information.
+			 * With lvmetad, this function does vg_lookup on this
+			 * name/vgid and checks system_id in the metadata.
+			 */
+			if (lvmcache_vg_is_foreign(cmd, vgnl->vg_name, vgnl->vgid)) {
+				id_write_format((const struct id*)vgnl->vgid, uuid, sizeof(uuid));
+				log_warn("WARNING: Ignoring foreign VG with matching name %s UUID %s.",
+					 vgnl->vg_name, uuid);
+				dm_list_del(&vgnl->list);
+			} else {
+				found++;
+			}
+		}
+
+		if (found < 2)
+			continue;
+
+		/*
+		 * More than one VG with this name is local so the intended VG
+		 * is unknown.
+		 */
+		log_error("Multiple VGs found with the same name: skipping %s", sl->str);
+		log_error("Use the VG UUID with --select vg_uuid=<uuid>");
+		dm_list_del(&sl->list);
+		ret = ECMD_FAILED;
+	}
+
+	return ret;
+}
+
+/*
  * For each arg_vgname, move the corresponding entry from
  * vgnameids_on_system to vgnameids_to_process.  If an
  * item in arg_vgnames doesn't exist in vgnameids_on_system,
@@ -2141,6 +2212,17 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		goto_out;
 	}
 
+	if (!dm_list_empty(&arg_vgnames)) {
+		/* This may remove entries from arg_vgnames or vgnameids_on_system. */
+		ret = _resolve_duplicate_vgnames(cmd, &arg_vgnames, &vgnameids_on_system);
+		if (ret > ret_max)
+			ret_max = ret;
+		if (dm_list_empty(&arg_vgnames) && dm_list_empty(&arg_tags)) {
+			ret_max = ECMD_FAILED;
+			goto out;
+		}
+	}
+
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
 		log_verbose("No volume groups found.");
@@ -2646,6 +2728,17 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t rea
 		goto_out;
 	}
 
+	if (!dm_list_empty(&arg_vgnames)) {
+		/* This may remove entries from arg_vgnames or vgnameids_on_system. */
+		ret = _resolve_duplicate_vgnames(cmd, &arg_vgnames, &vgnameids_on_system);
+		if (ret > ret_max)
+			ret_max = ret;
+		if (dm_list_empty(&arg_vgnames) && dm_list_empty(&arg_tags)) {
+			ret_max = ECMD_FAILED;
+			goto out;
+		}
+	}
+
 	if (dm_list_empty(&arg_vgnames) && dm_list_empty(&vgnameids_on_system)) {
 		/* FIXME Should be log_print, but suppressed for reporting cmds */
 		log_verbose("No volume groups found.");


