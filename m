From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Sep 2022 20:15:22 +0000 (GMT)
Subject: main - change messages about libblkid features
Message-ID: <20220927201522.74D633858C2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50281e5710dd8cb50208614066ca52ac4574eda6
Commit:        50281e5710dd8cb50208614066ca52ac4574eda6
Parent:        3ca44e13beb8532d19828c71540af0d0307fd017
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 27 15:10:04 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 27 15:13:31 2022 -0500

change messages about libblkid features

remove message about missing libblkid features

change message recommending resize_fsadm when libblkid
features are not available.
---
 lib/device/dev-type.c   | 9 ---------
 lib/metadata/lv_manip.c | 2 +-
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index fb6e9a444..eb9e169bb 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -948,15 +948,6 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 
 	blkid_free_probe(probe);
 
-	/* We don't expect to get this info for luks */
-	if (strcmp(fsi->fstype, "crypto_LUKS") && (no_block_size || no_fslastblock || no_fsblocksize)) {
-		log_print("Missing libblkid %s%s%sfor %s",
-			  no_block_size ? "BLOCK_SIZE " : "",
-			  no_fslastblock ? "FSLASTBLOCK " : "",
-			  no_fsblocksize ? "FSBLOCKSIZE " : "",
-			  pathname);
-	}
-
 	if (fslastblock && fsblocksize)
 		fsi->fs_last_byte = fslastblock * fsblocksize;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f2ec5d99c..083e54150 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6024,7 +6024,7 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 			  display_lvname(lv), fsi->mount_dir);
 
 	if (!fsi->fs_last_byte) {
-		log_error("File system size unknown: update libblkid for FSLASTBLOCK, or see --fs resize_fsadm.");
+		log_error("File system device usage not available from libblkid, see --fs resize_fsadm.");
 		return 0;
 	}
 

