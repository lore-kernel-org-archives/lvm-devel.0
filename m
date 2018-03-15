From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:38 -0400
Subject: master - activation: check for prioritized_section
Message-ID: <201803151004.w2FA4cJr023648@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d794444715d9a762d2b6f06fe465ef6348085673
Commit:        d794444715d9a762d2b6f06fe465ef6348085673
Parent:        6365f011b00357e7f67fbe3aca0ca00ccf17ba66
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 15 10:28:43 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 11:01:04 2018 +0100

activation: check for prioritized_section

Detect we are in prioritezed section instead of critical one,
since these operation were supposed to NOT be happining during
whole set of operation.

This patch fixes verification of udev operations.
---
 lib/activate/fs.c       |    4 ++--
 lib/metadata/metadata.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index a0b8bff..498ec8f 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -441,7 +441,7 @@ static int _fs_op(fs_op_t type, const char *dev_dir, const char *vg_name,
 		  const char *lv_name, const char *dev, const char *old_lv_name,
 		  int check_udev)
 {
-	if (critical_section()) {
+	if (prioritized_section()) {
 		if (!_stack_fs_op(type, dev_dir, vg_name, lv_name, dev,
 				  old_lv_name, check_udev))
 			return_0;
@@ -487,7 +487,7 @@ int fs_rename_lv(const struct logical_volume *lv, const char *dev,
 
 void fs_unlock(void)
 {
-	if (!critical_section()) {
+	if (!prioritized_section()) {
 		log_debug_activation("Syncing device names");
 		/* Wait for all processed udev devices */
 		if (!dm_udev_wait(_fs_cookie))
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c529abf..2e77a55 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3862,7 +3862,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		lvmcache_label_scan(cmd);
 		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 1))) {
 			/* Independent MDAs aren't supported under low memory */
-			if (!cmd->independent_metadata_areas && critical_section())
+			if (!cmd->independent_metadata_areas && prioritized_section())
 				return_NULL;
 			lvmcache_force_next_label_scan();
 			lvmcache_label_scan(cmd);
@@ -4034,7 +4034,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			log_debug_metadata("Cached VG %s had incorrect PV list",
 					   vgname);
 
-			if (critical_section())
+			if (prioritized_section())
 				inconsistent = 1;
 			else {
 				release_vg(correct_vg);
@@ -4074,7 +4074,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		inconsistent = 0;
 
 		/* Independent MDAs aren't supported under low memory */
-		if (!cmd->independent_metadata_areas && critical_section())
+		if (!cmd->independent_metadata_areas && prioritized_section())
 			return_NULL;
 		lvmcache_force_next_label_scan();
 		lvmcache_label_scan(cmd);


