From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 16:59:37 -0400
Subject: master - lvmlockd: update method for changing clustered VG
Message-ID: <201806132059.w5DKxbaV026713@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e53cfc6a88d7acafde6ba3fa293bcf15b9a033bc
Commit:        e53cfc6a88d7acafde6ba3fa293bcf15b9a033bc
Parent:        9b79f0244a17c91d790e2114e1c912e5efe00a2f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 15:30:28 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 15:30:28 2018 -0500

lvmlockd: update method for changing clustered VG

The previous method for forcibly changing a clustered VG
to a local VG involved using -cn and locking_type 0.
Since those options are deprecated, replace it with
the same command used for other forced lock type changes:
vgchange --locktype none --lockopt force.
---
 lib/commands/toolcontext.h |    1 +
 lib/metadata/metadata.c    |    9 +++++++++
 man/lvmlockd.8_main        |    9 +++------
 tools/vgchange.c           |    1 +
 4 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index baecfbd..9849e5f 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -153,6 +153,7 @@ struct cmd_context {
 	unsigned include_shared_vgs:1;		/* report/display cmds can reveal lockd VGs */
 	unsigned include_active_foreign_vgs:1;	/* cmd should process foreign VGs with active LVs */
 	unsigned vg_read_print_access_error:1;	/* print access errors from vg_read */
+	unsigned force_access_clustered:1;
 	unsigned lockd_gl_disable:1;
 	unsigned lockd_vg_disable:1;
 	unsigned lockd_lv_disable:1;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 40854de..113c87c 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4689,6 +4689,15 @@ int vg_flag_write_locked(struct volume_group *vg)
 static int _access_vg_clustered(struct cmd_context *cmd, const struct volume_group *vg)
 {
 	if (vg_is_clustered(vg)) {
+		/*
+		 * force_access_clustered is only set when forcibly
+		 * converting a clustered vg to lock type none.
+		 */
+		if (cmd->force_access_clustered) {
+			log_debug("Allowing forced access to clustered vg %s", vg->name);
+			return 1;
+		}
+
 		if (!cmd->ignore_clustered_vgs)
 			log_error("Skipping clustered volume group %s", vg->name);
 		else
diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index cf4c52e..6411c01 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -814,8 +814,8 @@ dlm), first change it to a local VG, then to the new type.
 
 All LVs must be inactive to change the lock type.
 
-First change the clvm VG to a local VG.  Within a running clvm cluster,
-change a clvm VG to a local VG with the command:
+First change the clvm/clustered VG to a local VG.  Within a running clvm
+cluster, change a clustered VG to a local VG with the command:
 
 vgchange -cn <vgname>
 
@@ -823,10 +823,7 @@ If the clvm cluster is no longer running on any nodes, then extra options
 can be used to forcibly make the VG local.  Caution: this is only safe if
 all nodes have stopped using the VG:
 
-vgchange --config 'global/locking_type=0 global/use_lvmlockd=0'
-.RS
--cn <vgname>
-.RE
+vgchange  --lock-type none --lock-opt force <vgname>
 
 After the VG is local, follow the steps described in "changing a local VG
 to a lockd VG".
diff --git a/tools/vgchange.c b/tools/vgchange.c
index b427a81..891f22a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1039,6 +1039,7 @@ int vgchange_locktype_cmd(struct cmd_context *cmd, int argc, char **argv)
 		cmd->lockd_vg_disable = 1;
 		cmd->lockd_lv_disable = 1;
 		cmd->handles_missing_pvs = 1;
+		cmd->force_access_clustered = 1;
 		goto process;
 	}
 


