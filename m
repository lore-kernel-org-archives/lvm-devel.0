From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:03:58 +0000 (UTC)
Subject: dev-mornfall-lvmcache - cleanup: drop backtrace
Message-ID: <20130605120358.1274860F18@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ba3bc0d6641db5b02e63759949388a840f58d48
Commit:        3ba3bc0d6641db5b02e63759949388a840f58d48
Parent:        58a2e5e2df4049108b1ba0fe970fd88eba9a3290
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 23 16:17:08 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 27 10:28:32 2013 +0200

cleanup: drop backtrace

After log_error/log_warn there is no point to show <backtrace>
in debug log trace from the next code line.
---
 lib/activate/activate.c |    4 ++--
 lib/metadata/metadata.c |    8 ++++----
 libdm/libdm-deptree.c   |    8 ++++----
 tools/pvmove.c          |    2 +-
 tools/vgextend.c        |    4 ++--
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6c368b9..bb8f6f9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2019,13 +2019,13 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
 		log_error("Refusing activation of partial LV %s. Use --partial to override.",
 			  lv->name);
-		goto_out;
+		goto out;
 	}
 
 	if (lv_has_unknown_segments(lv)) {
 		log_error("Refusing activation of LV %s containing "
 			  "an unrecognised segment.", lv->name);
-		goto_out;
+		goto out;
 	}
 
 	if (test_mode()) {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 357e849..78841c3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4009,7 +4009,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		if (consistent_in && !consistent) {
 			log_error("Volume group \"%s\" inconsistent.", vg_name);
 			failure |= FAILED_INCONSISTENT;
-			goto_bad;
+			goto bad;
 		}
 
 		log_error("Volume group \"%s\" not found", vg_name);
@@ -4031,7 +4031,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 			log_error("Recovery of volume group \"%s\" failed.",
 				  vg_name);
 			failure |= FAILED_INCONSISTENT;
-			goto_bad;
+			goto bad;
 		}
 	}
 
@@ -4045,7 +4045,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		log_error("Cannot change VG %s while PVs are missing.", vg->name);
 		log_error("Consider vgreduce --removemissing.");
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
-		goto_bad;
+		goto bad;
 	}
 
 	if (!cmd->handles_unknown_segments && vg_has_unknown_segments(vg) &&
@@ -4053,7 +4053,7 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		log_error("Cannot change VG %s with unknown segments in it!",
 			  vg->name);
 		failure |= FAILED_INCONSISTENT; /* FIXME new failure code here? */
-		goto_bad;
+		goto bad;
 	}
 
 	failure |= _vg_bad_status_bits(vg, status_flags);
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index b084bc0..115754b 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -851,13 +851,13 @@ static int _info_by_dev(uint32_t major, uint32_t minor, int with_open_count,
 	if (name && !(*name = dm_pool_strdup(mem, dm_task_get_name(dmt)))) {
 		log_error("name pool_strdup failed");
 		r = 0;
-		goto_out;
+		goto out;
 	}
 
 	if (uuid && !(*uuid = dm_pool_strdup(mem, dm_task_get_uuid(dmt)))) {
 		log_error("uuid pool_strdup failed");
 		r = 0;
-		goto_out;
+		goto out;
 	}
 
 out:
@@ -1016,13 +1016,13 @@ static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 
 	if (!(dmt = dm_task_create(DM_DEVICE_CLEAR))) {
 		log_error("Table clear dm_task creation failed for %s", name);
-		goto_out;
+		goto out;
 	}
 
 	if (!dm_task_set_major(dmt, info->major) ||
 	    !dm_task_set_minor(dmt, info->minor)) {
 		log_error("Failed to set device number for %s table clear", name);
-		goto_out;
+		goto out;
 	}
 
 	r = dm_task_run(dmt);
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 5c51c5f..cbfed3c 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -464,7 +464,7 @@ static int _update_metadata(struct cmd_context *cmd, struct volume_group *vg,
 			 * FIXME Run --abort internally here.
 			 */
 			log_error("ABORTING: Temporary pvmove mirror activation failed. Run pvmove --abort.");
-			goto_out;
+			goto out;
 		}
 	}
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 2ce7edb..93d55a0 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -92,7 +92,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		}
 		if (!fixed) {
 			log_error("No PV has been restored.");
-			goto_bad;
+			goto bad;
 		}
 	} else { /* no --restore, normal vgextend */
 		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
@@ -108,7 +108,7 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 			  "of VG %s metadata? [y/n]: ",
 				  vg_name) == 'n') {
 			log_error("Volume group %s not changed", vg_name);
-			goto_bad;
+			goto bad;
 		}
 
 		/* extend vg */


