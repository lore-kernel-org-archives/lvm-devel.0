From: David Teigland <teigland@sourceware.org>
Date: Tue, 31 Jan 2023 21:30:18 +0000 (GMT)
Subject: main - lvresize: fail early if crypt device is missing
Message-ID: <20230131213018.161063858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9f8acb65a78c20ac806efaeb7a1e39208e1a443
Commit:        d9f8acb65a78c20ac806efaeb7a1e39208e1a443
Parent:        5374a44c57127cdd832a675545c1d2bbf0b3751a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 30 17:12:11 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 30 17:12:11 2023 -0600

lvresize: fail early if crypt device is missing

If extending an LV with crypto_LUKS on it, and the crypt device
is missing, then fail the command before extending the LV.
---
 lib/device/filesystem.c | 15 ++++++++++++++-
 lib/device/filesystem.h |  2 ++
 lib/metadata/lv_manip.c |  4 ++++
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index db507bdda..c9cc7c553 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -94,6 +94,19 @@ static int _get_crypt_path(dev_t lv_devt, char *lv_path, char *crypt_path)
 	return ret;
 }
 
+int lv_crypt_is_active(struct cmd_context *cmd, char *lv_path)
+{
+	char crypt_path[PATH_MAX];
+	struct stat st_lv;
+
+	if (stat(lv_path, &st_lv) < 0) {
+		log_error("Failed to get LV path %s", lv_path);
+		return 0;
+	}
+
+	return _get_crypt_path(st_lv.st_rdev, lv_path, crypt_path);
+}
+
 int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 		struct fs_info *fsi, int include_mount)
 {
@@ -149,7 +162,7 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 
 		memset(&info, 0, sizeof(info));
 
-		log_print("File system found on crypt device %s on LV %s.",
+		log_print("Checking crypt device %s on LV %s.",
 			  crypt_path, display_lvname(lv));
 
 		if ((fd = open(crypt_path, O_RDONLY)) < 0) {
diff --git a/lib/device/filesystem.h b/lib/device/filesystem.h
index 77eac34d0..cbc7b5352 100644
--- a/lib/device/filesystem.h
+++ b/lib/device/filesystem.h
@@ -50,4 +50,6 @@ int crypt_resize_script(struct cmd_context *cmd, struct logical_volume *lv, stru
 		uint64_t newsize_bytes_fs);
 
 int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *lv, char *lv_path, char *fstype);
+int lv_crypt_is_active(struct cmd_context *cmd, char *lv_path);
+
 #endif
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fa6393a48..2a4e0e88a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6939,6 +6939,10 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 			log_error("File system not found for --resizefs or --fs options.");
 			goto out;
 		}
+		if (!strcmp(fstype, "crypto_LUKS") && !lv_crypt_is_active(cmd, lv_path)) {
+			log_error("LUKS dm-crypt device must be active for fs resize.");
+			goto out;
+		}
 		/* FS utils will fail if LVs were renamed while mounted. */
 		if (fs_mount_state_is_misnamed(cmd, lv_top, lv_path, fstype))
 			goto_out;

