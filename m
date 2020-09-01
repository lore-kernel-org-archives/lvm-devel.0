From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  1 Sep 2020 17:02:07 +0000 (GMT)
Subject: master - cov: always initialized values
Message-ID: <20200901170207.9532A3951C4C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a481f4263093d45eb4c4a7912ab3c6069ed05df9
Commit:        a481f4263093d45eb4c4a7912ab3c6069ed05df9
Parent:        85e2c7e14dc888e54174222600fc38470ab035df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Aug 29 20:27:32 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 1 17:57:50 2020 +0200

cov: always initialized values

Make sure values are initialized for all possible paths.
---
 lib/device/dev-md.c | 2 +-
 lib/label/hints.c   | 2 +-
 tools/lvconvert.c   | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 8fe7fc361..36494b12b 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -176,7 +176,7 @@ static int _udev_dev_is_md_component(struct device *dev)
  */
 static int _native_dev_is_md_component(struct device *dev, uint64_t *offset_found, int full)
 {
-	uint64_t size, sb_offset;
+	uint64_t size, sb_offset = 0;
 	int ret;
 
 	if (!scan_bcache)
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 55f55900d..8da131428 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -663,7 +663,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	int found = 0;
 	int keylen;
 	int hv_major, hv_minor;
-	int major, minor;
+	int major = -1, minor = -1;
 	int ret = 1;
 	int i;
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c95287a78..04ec1ee4f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5614,7 +5614,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	uint32_t block_size = 0;
 	int lbs_unknown = 0, lbs_4k = 0, lbs_512 = 0;
 	int pbs_unknown = 0, pbs_4k = 0, pbs_512 = 0;
-	int rv;
+	int rv = 0;
 
 	/* This is set if the user specified a writecache block size on the command line. */
 	if (*block_size_sectors)


