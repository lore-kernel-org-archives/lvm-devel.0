From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 27 Apr 2016 20:45:57 +0000 (UTC)
Subject: master - pvscan: autoactivation should ignore some VGs
Message-ID: <20160427204557.55B0C60535@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2d2a61339b83de0d48ed6ed15e816773393c6b4
Commit:        a2d2a61339b83de0d48ed6ed15e816773393c6b4
Parent:        263c1a4db51184c718e85c1c3fdcef7908dd7c88
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 27 15:33:23 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 27 15:45:38 2016 -0500

pvscan: autoactivation should ignore some VGs

pvscan autoactivation has its own VG processing implementation,
so it can't properly handle things like foreign or shared VGs,
so make it ignore those VG types (or errors from them) as best
as possible.

Add a FIXME stating that pvscan autoactivation must really be
moved to the standard VG processing by calling process_each_vg
to do activation once the scanning / cache update is finished.
---
 tools/pvscan.c |   34 ++++++++++++++++++++++++++++++++--
 1 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 425383a..d93773a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -132,6 +132,7 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	int refresh_done = 0;
 	struct volume_group *vg;
 	struct id vgid_raw;
+	uint32_t read_error;
 	int r = 0;
 
 	/* TODO: add support for partial and clustered VGs */
@@ -141,16 +142,45 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	if (!id_read_format(&vgid_raw, vgid))
 		return_0;
 
+	/*
+	 * FIXME: pvscan activation really needs to be changed to use
+	 * the standard process_each_vg() interface.  It should save
+	 * a list of VG names that are found during the scan, then
+	 * call process_each_vg() with that list to do activation.
+	 */
+
+	cmd->vg_read_print_access_error = 0;
+
 	/* NB. This is safe because we know lvmetad is running and we won't hit disk. */
 	vg = vg_read(cmd, vgname, (const char *)&vgid_raw, 0, 0);
-	if (vg_read_error(vg)) {
+	read_error = vg_read_error(vg);
+	if (read_error) {
+		/*
+		 * foreign VGs: we want to read and update lvmetad, but that's
+		 * all, we don't want to even attempt to autoactivate.
+		 *
+		 * shared VGs: we want to read and update lvmetad, and for now
+		 * ignore them for autoactivation.  Once pvscan autoactivation
+		 * uses process_each_vg, then shared VGs could be autoactivated.
+		 */
+		if (read_error & (FAILED_SYSTEMID | FAILED_LOCK_TYPE | FAILED_LOCK_MODE)) {
+			release_vg(vg);
+			return 1;
+		}
+
 		log_error("Failed to read Volume Group \"%s\" (%s) during autoactivation.", vgname, vgid);
 		release_vg(vg);
 		return 0;
 	}
 
+	if (is_lockd_type(vg->lock_type)) {
+		r = 1;
+		goto out;
+	}
+
 	if (vg_is_clustered(vg)) {
-		r = 1; goto out;
+		r = 1;
+		goto out;
 	}
 
 	/* FIXME: There's a tiny race when suspending the device which is part


