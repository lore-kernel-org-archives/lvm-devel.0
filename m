From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:08 +0000 (GMT)
Subject: main - cov: some initializers
Message-ID: <20230506204608.8DB183858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39b2bd06b8a992607ef6a315b08d2bf97cc6f24f
Commit:        39b2bd06b8a992607ef6a315b08d2bf97cc6f24f
Parent:        4fd2f433ad7d49b404a897c64191826e7b3c9f4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 14:15:21 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 19:22:05 2023 +0200

cov: some initializers

---
 lib/device/dev-type.c   | 6 +++---
 lib/device/filesystem.c | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 8b51a672a..999b939c5 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -827,7 +827,7 @@ int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes,
 {
 	blkid_probe probe = NULL;
 	const char *type_str = NULL, *size_str = NULL;
-	size_t len;
+	size_t len = 0;
 	int ret = 1;
 	int rc;
 
@@ -887,8 +887,8 @@ out:
 int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 {
 	blkid_probe probe = NULL;
-	const char *str;
-	size_t len;
+	const char *str = "";
+	size_t len = 0;
 	uint64_t fslastblock = 0;
 	unsigned int fsblocksize = 0;
 	int rc;
diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index 2163276ed..5ec090a2c 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -96,7 +96,7 @@ static int _get_crypt_path(dev_t lv_devt, char *lv_path, char *crypt_path)
 
 int lv_crypt_is_active(struct cmd_context *cmd, char *lv_path)
 {
-	char crypt_path[PATH_MAX];
+	char crypt_path[PATH_MAX] = { 0 };
 	struct stat st_lv;
 
 	if (stat(lv_path, &st_lv) < 0) {
@@ -111,7 +111,7 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 		struct fs_info *fsi, int include_mount)
 {
 	char lv_path[PATH_MAX];
-	char crypt_path[PATH_MAX];
+	char crypt_path[PATH_MAX] = { 0 };
 	struct stat st_lv;
 	struct stat st_crypt;
 	struct stat st_top;
@@ -234,7 +234,7 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 	char proc_fstype[FSTYPE_MAX];
 	char proc_devpath[PATH_MAX];
 	char proc_mntpath[PATH_MAX];
-	char mtab_mntpath[PATH_MAX];
+	char mtab_mntpath[PATH_MAX] = { 0 };
 	char dm_devpath[PATH_MAX];
 	char tmp_path[PATH_MAX];
 	char *dm_name;

