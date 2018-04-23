From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:48:59 -0400
Subject: master - vgcreate: improve the use of label_scan
Message-ID: <201804231348.w3NDmx5N031558@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f138f36040297d092977a3b547cdefffb5ac4e8
Commit:        5f138f36040297d092977a3b547cdefffb5ac4e8
Parent:        e3e5beec74ac0037917f5e9a2693c6ccb16debac
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 26 14:32:30 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:45 2018 -0500

vgcreate: improve the use of label_scan

The old code was doing unnecessary label scans when
checking to see if the new VG name exists.  A single
label_scan is sufficient if it is done after the
new VG lock is held.
---
 tools/vgcreate.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index af0c363..87a296f 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -26,7 +26,6 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 	const char *clustered_message = "";
 	char *vg_name;
 	struct arg_value_group_list *current_group;
-	uint32_t rc;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -66,17 +65,30 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	cmd->lockd_gl_disable = 1;
 
-	lvmcache_seed_infos_from_lvmetad(cmd);
-
 	/*
 	 * Check if the VG name already exists.  This should be done before
 	 * creating PVs on any of the devices.
+	 *
+	 * When searching if a VG name exists, acquire the VG lock,
+	 * then do the initial label scan which reads all devices and
+	 * populates lvmcache with any VG name it finds.  If the VG name
+	 * we want to use exists, then the label scan will find it,
+	 * and the fmt_from_vgname call (used to check if the name exists)
+	 * will return non-NULL.
 	 */
-	if ((rc = vg_lock_newname(cmd, vp_new.vg_name)) != SUCCESS) {
-		if (rc == FAILED_EXIST)
-			log_error("A volume group called %s already exists.", vp_new.vg_name);
-		else
-			log_error("Can't get lock for %s.", vp_new.vg_name);
+
+	if (!lock_vol(cmd, vp_new.vg_name, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for %s.", vp_new.vg_name);
+		return ECMD_FAILED;
+	}
+
+	lvmcache_force_next_label_scan();
+	lvmcache_label_scan(cmd);              /* Does nothing when using lvmetad. */
+	lvmcache_seed_infos_from_lvmetad(cmd); /* Does nothing unless using lvmetad. */
+
+	if (lvmcache_fmt_from_vgname(cmd, vp_new.vg_name, NULL, 0)) {
+		unlock_vg(cmd, NULL, vp_new.vg_name);
+		log_error("A volume group called %s already exists.", vp_new.vg_name);
 		return ECMD_FAILED;
 	}
 


