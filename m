From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 27 Nov 2012 13:28:42 +0000 (UTC)
Subject: master - thin: allow restore with --force
Message-ID: <20121127132842.9D64C1405@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09b7ceea95edb2b54074cbd5d3b2009b5bf1dd4e
Commit:        09b7ceea95edb2b54074cbd5d3b2009b5bf1dd4e
Parent:        c7a7fd0a12d0daef70e3c4517ccdef6830c7a34e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 26 23:45:35 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 27 14:08:24 2012 +0100

thin: allow restore with --force

Allow restoring metadata with thin pool volumes.
No validation is done for this case within vgcfgrestore tool -
thus incorrect metadata may lead to destruction of pool content.
---
 WHATS_NEW                  |    1 +
 lib/format_text/archiver.c |   24 +++++++++++++++---------
 lib/format_text/archiver.h |    4 ++--
 man/vgcfgrestore.8.in      |    9 +++++++++
 tools/args.h               |    1 +
 tools/commands.h           |    3 ++-
 tools/vgcfgrestore.c       |    5 +++--
 7 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c6ad4c..1655a7e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Allow forced vgcfgrestore of lvm2 metadata with thin volumes.
   Recognise STEC skd devices in filter.
   Recognise Violin Memory vtms devices in filter.
   Add lvm.conf thin pool defs thin_pool_{chunk_size|discards|zero}.
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index ccefb4c..8599e3b 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -347,7 +347,7 @@ int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg)
 
 /* ORPHAN and VG locks held before calling this */
 int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
-			     const char *file)
+			     const char *file, int force)
 {
 	struct volume_group *vg;
 	int missing_pvs, r = 0;
@@ -360,14 +360,20 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 		return_0;
 
 	/* FIXME: Restore support is missing for now */
-	dm_list_iterate_items(lvl, &vg->lvs)
+	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lv_is_thin_type(lvl->lv)) {
-			log_error("Cannot restore Volume Group %s with "
-				  "thin logical volumes. "
-				  "(not yet supported).", vg->name);
-			r = 0;
-			goto out;
+			if (!force) {
+				log_error("Consider using option --force to restore "
+					  "Volume Group %s with thin volumes.",
+					  vg->name);
+				goto out;
+			} else {
+				log_warn("WARNING: Forced restore of Volume Group "
+					 "%s with thin volumes.", vg->name);
+				break;
+			}
 		}
+	}
 
 	missing_pvs = vg_missing_pv_count(vg);
 	if (missing_pvs == 0)
@@ -381,7 +387,7 @@ out:
 	return r;
 }
 
-int backup_restore(struct cmd_context *cmd, const char *vg_name)
+int backup_restore(struct cmd_context *cmd, const char *vg_name, int force)
 {
 	char path[PATH_MAX];
 
@@ -391,7 +397,7 @@ int backup_restore(struct cmd_context *cmd, const char *vg_name)
 		return 0;
 	}
 
-	return backup_restore_from_file(cmd, vg_name, path);
+	return backup_restore_from_file(cmd, vg_name, path, force);
 }
 
 int backup_to_file(const char *file, const char *desc, struct volume_group *vg)
diff --git a/lib/format_text/archiver.h b/lib/format_text/archiver.h
index 7346f93..ddff687 100644
--- a/lib/format_text/archiver.h
+++ b/lib/format_text/archiver.h
@@ -53,8 +53,8 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 				    const char *vg_name, const char *file);
 int backup_restore_vg(struct cmd_context *cmd, struct volume_group *vg);
 int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
-			     const char *file);
-int backup_restore(struct cmd_context *cmd, const char *vg_name);
+			     const char *file, int force);
+int backup_restore(struct cmd_context *cmd, const char *vg_name, int force);
 
 int backup_to_file(const char *file, const char *desc, struct volume_group *vg);
 
diff --git a/man/vgcfgrestore.8.in b/man/vgcfgrestore.8.in
index 3b7b038..7b8dd59 100644
--- a/man/vgcfgrestore.8.in
+++ b/man/vgcfgrestore.8.in
@@ -6,6 +6,7 @@ vgcfgrestore \- restore volume group descriptor area
 .RB [ \-d | \-\-debug ]
 .RB [ \-f | \-\-file
 .RI < filename >]
+.RB [ \-\-force ]
 .RB [ \-l [ l ]| \-\-list ]
 .RB [ \-h | \-\-help ]
 .RB [ \-M | \-\-metadatatype
@@ -32,6 +33,14 @@ May be used with the \fB\-f\fP option.  Does not restore \fIVolumeGroupName\fP.
 Name of LVM metadata backup file
 Specifies a metadata backup or archive file to be used for restoring 
 VolumeGroupName.  Often this file has been created with \fBvgcfgbackup\fP.
+.TP
+.B \-\-force
+To restore metadata with thin pool volumes, user currently
+needs to use this flag. The tool DOES NOT make any validation.
+.br
+WARNING: Restoring lvm2 metadata that are not matching thin pool
+kernel metadata may lead to the destruction of the pool content.
+Use with extreme caution.
 .SH REPLACING PHYSICAL VOLUMES
 \fBvgdisplay \-\-partial \-\-verbose\fP will show you the UUIDs and sizes of
 any PVs that are no longer present.
diff --git a/tools/args.h b/tools/args.h
index 0d9605a..d4d6c40 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -73,6 +73,7 @@ arg(poll_ARG, '\0', "poll", yes_no_arg, 0)
 arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0)
 arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0)
 arg(discards_ARG, '\0', "discards", discards_arg, 0)
+arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 8d5d190..986539e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -725,6 +725,7 @@ xx(vgcfgrestore,
    "vgcfgrestore " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-f|--file filename] " "\n"
+   "\t[--force]\n"
    "\t[-l[l]|--list [--list]]" "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[-h|--help]" "\n"
@@ -733,7 +734,7 @@ xx(vgcfgrestore,
    "\t[--version] " "\n"
    "\tVolumeGroupName",
 
-   file_ARG, list_ARG, metadatatype_ARG, test_ARG)
+   file_ARG, force_long_ARG, list_ARG, metadatatype_ARG, test_ARG)
 
 xx(vgchange,
    "Change volume group attributes",
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index d62df99..20ca16b 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -62,8 +62,9 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!(arg_count(cmd, file_ARG) ?
 	      backup_restore_from_file(cmd, vg_name,
-				       arg_str_value(cmd, file_ARG, "")) :
-	      backup_restore(cmd, vg_name))) {
+				       arg_str_value(cmd, file_ARG, ""),
+				       arg_count(cmd, force_long_ARG)) :
+	      backup_restore(cmd, vg_name, arg_count(cmd, force_long_ARG)))) {
 		unlock_vg(cmd, VG_ORPHANS);
 		unlock_vg(cmd, vg_name);
 		log_error("Restore failed.");


