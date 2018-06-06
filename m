From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Jun 2018 17:36:55 -0400
Subject: master - use exclusive file lock on VG for activation
Message-ID: <201806062136.w56LatKv022716@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58a9254252a4c837601c15aabdae53d2f3c06edc
Commit:        58a9254252a4c837601c15aabdae53d2f3c06edc
Parent:        d2d8dd7f7f21798cac37d9cc6a7cdcb290a63f4f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 11:14:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 6 13:58:34 2018 -0500

use exclusive file lock on VG for activation

Make activation commands:
  vgchange -ay, lvchange -ay, pvscan -aay

take an exclusive file lock on the VG to serialize
multiple concurrent activation commands which could
otherwise interfere with each other.
---
 tools/lvchange.c |    2 +-
 tools/pvscan.c   |    2 +-
 tools/vgchange.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index a90174e..3ed6b06 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1386,7 +1386,7 @@ int lvchange_activate_cmd(struct cmd_context *cmd, int argc, char **argv)
 	} else /* Component LVs might be active, support easy deactivation */
 		cmd->process_component_lvs = 1;
 
-	ret = process_each_lv(cmd, argc, argv, NULL, NULL, 0,
+	ret = process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
 			      NULL, &_lvchange_activate_check, &_lvchange_activate_single);
 
 	if (ret != ECMD_PROCESSED)
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 7cba0f4..61626e6 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -288,7 +288,7 @@ static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params
 		pp->refresh_all = 1;
 	}
 
-	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, 0, 0, handle, _pvscan_autoactivate_single);
+	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, READ_FOR_UPDATE, 0, handle, _pvscan_autoactivate_single);
 
 	destroy_processing_handle(cmd, handle);
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a67c3be..b07057f 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -791,7 +791,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 			cmd->lockd_vg_enforce_sh = 1;
 	}
 
-	if (update)
+	if (update || arg_is_set(cmd, activate_ARG))
 		flags |= READ_FOR_UPDATE;
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {


