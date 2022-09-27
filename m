From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Sep 2022 20:46:35 +0000 (GMT)
Subject: main - remove unused variables
Message-ID: <20220927204635.866E33858C2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f1ef25b46cc96a2f8dce5beac57362370274261
Commit:        7f1ef25b46cc96a2f8dce5beac57362370274261
Parent:        50281e5710dd8cb50208614066ca52ac4574eda6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 27 15:40:39 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 27 15:42:18 2022 -0500

remove unused variables

---
 lib/device/dev-type.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index eb9e169bb..bb8925483 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -893,7 +893,6 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 	size_t len;
 	uint64_t fslastblock = 0;
 	unsigned int fsblocksize = 0;
-	int no_block_size = 0, no_fslastblock = 0, no_fsblocksize = 0;
 	int rc;
 
 	if (!(probe = blkid_new_probe_from_filename(pathname))) {
@@ -933,18 +932,12 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 
 	if (!blkid_probe_lookup_value(probe, "BLOCK_SIZE", &str, &len) && len)
 		fsi->fs_block_size_bytes = atoi(str);
-	else
-		no_block_size = 1;
 
 	if (!blkid_probe_lookup_value(probe, "FSLASTBLOCK", &str, &len) && len)
 		fslastblock = strtoull(str, NULL, 0);
-	else
-		no_fslastblock = 1;
 
 	if (!blkid_probe_lookup_value(probe, "FSBLOCKSIZE", &str, &len) && len)
 		fsblocksize = (unsigned int)atoi(str);
-	else
-		no_fsblocksize = 1;
 
 	blkid_free_probe(probe);
 

