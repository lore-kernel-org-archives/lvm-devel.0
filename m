From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  2 Sep 2013 11:54:15 +0000 (UTC)
Subject: master - revert: commit 82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
Message-ID: <20130902115415.E6189614F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=44c1a02c1805ec4487af1bc3057fcd8e40f8a375
Commit:        44c1a02c1805ec4487af1bc3057fcd8e40f8a375
Parent:        039585bb0d0cccb4c30c1f3fafe007e24ad101b6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 2 13:46:49 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 2 13:53:27 2013 +0200

revert: commit 82d83a01ce2cac77fec2e9b763061fbfb5f01ce8

The commit 82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
"autoactivation: refresh existing VG before autoactivation"
causes problems (dangling udev_sync cookies, slow processing
of the pvscan --cache --major --minor call from udev rules)
when the autoactivation handler is run in parallel on
several PVs that belong to the same VG. Revert this patch
until the exact source of the problem is found and then
properly fixed and handled.
---
 WHATS_NEW      |    1 -
 tools/pvscan.c |   20 +++++++-------------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c56be6d..f1a9933 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -14,7 +14,6 @@ Version 2.02.101 -
   Prevent cluster mirror logs from being corrupted by redundant checkpoints.
   Fix ignored lvmetad update on loop device configuration (2.02.99).
   Use LVM_PATH instead of hardcoded value in lvm2 activation systemd generator.
-  Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Fix vgck to notice on-disk corruption even if lvmetad is used.
   Move mpath device filter before partitioned filter (which opens devices).
   Split partitioned filter out of lvm_type filter.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 3f16b05..96bbf6b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -98,7 +98,6 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	struct volume_group *vg;
 	int consistent = 0;
 	struct id vgid_raw;
-	int r = 0;
 
 	/* TODO: add support for partial and clustered VGs */
 	if (partial)
@@ -107,29 +106,24 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	if (!id_read_format(&vgid_raw, vgid))
 		return_0;
 
-	/* NB. This is safe because we know lvmetad is running and we won't hit disk. */
+	/* NB. This is safe because we know lvmetad is running and we won't hit
+	 * disk. */
 	if (!(vg = vg_read_internal(cmd, NULL, (const char *) &vgid_raw, 0, &consistent)))
 	    return 1;
 
 	if (vg_is_clustered(vg)) {
-		r = 1; goto out;
-	}
-
-	if (!vg_refresh_visible(vg->cmd, vg)) {
-		log_error("%s: refresh before autoactivation failed.", vg->name);
-		goto out;
+		release_vg(vg);
+		return 1;
 	}
 
 	if (!vgchange_activate(vg->cmd, vg, activate)) {
 		log_error("%s: autoactivation failed.", vg->name);
-		goto out;
+		release_vg(vg);
+		return 0;
 	}
 
-	r = 1;
-
-out:
 	release_vg(vg);
-	return r;
+	return 1;
 }
 
 static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)


