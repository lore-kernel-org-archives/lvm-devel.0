From: David Teigland <teigland@sourceware.org>
Date: Wed, 28 Sep 2022 16:54:51 +0000 (GMT)
Subject: main - lvresize: give special advice to reiserfs users
Message-ID: <20220928165451.2761C3858016@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a0052a1d3b06a071ff6197fc41d9fa312827538
Commit:        5a0052a1d3b06a071ff6197fc41d9fa312827538
Parent:        1924fed30807ac0d355d2c6527d2f0a1d7efafcc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 28 11:52:40 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 28 11:54:13 2022 -0500

lvresize: give special advice to reiserfs users

---
 lib/metadata/lv_manip.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 083e54150..99045c220 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6024,7 +6024,11 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 			  display_lvname(lv), fsi->mount_dir);
 
 	if (!fsi->fs_last_byte) {
-		log_error("File system device usage not available from libblkid, see --fs resize_fsadm.");
+		if (!strcmp(fsi->fstype, "reiserfs")) {
+			log_error("File system reduce for reiserfs requires --fs resize_fsadm.");
+			return 0;
+		}
+		log_error("File system device usage is not available from libblkid.");
 		return 0;
 	}
 
@@ -6064,6 +6068,9 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	if (is_ext_fstype) {
 		log_print("File system reduce is required using resize2fs.");
+	} else if (!strcmp(fsi->fstype, "reiserfs")) {
+		log_error("File system reduce for reiserfs requires --fs resize_fsadm.");
+		return 0;
 	} else {
 		log_error("File system reduce is required and not supported (%s).", fsi->fstype);
 		return 0;
@@ -6181,6 +6188,9 @@ static int _fs_extend_allow(struct cmd_context *cmd, struct logical_volume *lv,
 			  fsi->fstype, (unsigned long long)fsi->fs_last_byte);
 		if (!strncmp(fsi->fstype, "ext", 3))
 			is_ext_fstype = 1;
+	} else if (!strcmp(fsi->fstype, "reiserfs")) {
+		log_error("File system extend for reiserfs requires --fs resize_fsadm.");
+		return 0;
 	} else {
 		log_error("File system extend is not supported (%s).", fsi->fstype);
 		return 0;

