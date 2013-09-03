From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  3 Sep 2013 14:49:33 +0000 (UTC)
Subject: master - reinstate: commit 82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
Message-ID: <20130903144933.17BA960DCB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b51f298bb505e5184b715032872e5cd1ce2d544
Commit:        3b51f298bb505e5184b715032872e5cd1ce2d544
Parent:        008c33a21ba0e0fb27319b63c7bad8fb8136f804
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 3 16:45:18 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 3 16:49:21 2013 +0200

reinstate: commit 82d83a01ce2cac77fec2e9b763061fbfb5f01ce8

It now works as supposed. The source of the problem is fixed
by previous commit d2d6a9da52e04f28e1916bcea3f9fda356b6df29.
---
 WHATS_NEW      |    1 +
 tools/pvscan.c |   20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c87bce1..8134714 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Refresh existing VG before autoactivation (event retrigger/device reappeared).
   Use pvscan -b in udev rules to avoid a deadlock on udev process count limit.
   Add pvscan -b/--background for the command to be processed in the background.
   Don't assume stdin file descriptor is readable.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 96bbf6b..3f16b05 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -98,6 +98,7 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	struct volume_group *vg;
 	int consistent = 0;
 	struct id vgid_raw;
+	int r = 0;
 
 	/* TODO: add support for partial and clustered VGs */
 	if (partial)
@@ -106,24 +107,29 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	if (!id_read_format(&vgid_raw, vgid))
 		return_0;
 
-	/* NB. This is safe because we know lvmetad is running and we won't hit
-	 * disk. */
+	/* NB. This is safe because we know lvmetad is running and we won't hit disk. */
 	if (!(vg = vg_read_internal(cmd, NULL, (const char *) &vgid_raw, 0, &consistent)))
 	    return 1;
 
 	if (vg_is_clustered(vg)) {
-		release_vg(vg);
-		return 1;
+		r = 1; goto out;
+	}
+
+	if (!vg_refresh_visible(vg->cmd, vg)) {
+		log_error("%s: refresh before autoactivation failed.", vg->name);
+		goto out;
 	}
 
 	if (!vgchange_activate(vg->cmd, vg, activate)) {
 		log_error("%s: autoactivation failed.", vg->name);
-		release_vg(vg);
-		return 0;
+		goto out;
 	}
 
+	r = 1;
+
+out:
 	release_vg(vg);
-	return 1;
+	return r;
 }
 
 static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)


