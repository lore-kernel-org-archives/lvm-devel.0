From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Oct 2020 20:56:43 +0000 (GMT)
Subject: stable-2.02 - gcc: cleanup warns from older gcc
Message-ID: <20201025205643.DCD953857C62@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=da7ec2ec0f19dca9266ecb2a653485491cae850a
Commit:        da7ec2ec0f19dca9266ecb2a653485491cae850a
Parent:        50ac89448fef4fc223e52f5a843b0709111006cb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 21:56:02 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 21:56:02 2020 +0100

gcc: cleanup warns from older gcc

---
 lib/device/dev-md.c     | 2 +-
 lib/display/display.c   | 4 ++--
 lib/metadata/lv_manip.c | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index e345e926c..e28a8c183 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -173,7 +173,7 @@ static int _udev_dev_is_md(struct device *dev)
  */
 static int _native_dev_is_md(struct device *dev, uint64_t *offset_found, int full)
 {
-	uint64_t size, sb_offset;
+	uint64_t size, sb_offset = 0;
 	int ret;
 
 	if (!scan_bcache)
diff --git a/lib/display/display.c b/lib/display/display.c
index d8220397b..e9cfaa985 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -407,9 +407,9 @@ int lvdisplay_full(struct cmd_context *cmd,
 	int lvm1compat;
 	dm_percent_t snap_percent;
 	int thin_pool_active = 0;
-	dm_percent_t thin_data_percent, thin_metadata_percent;
+	dm_percent_t thin_data_percent = 0, thin_metadata_percent = 0;
 	int thin_active = 0;
-	dm_percent_t thin_percent;
+	dm_percent_t thin_percent = 0;
 	struct lv_status_thin *thin_status = NULL;
 	struct lv_status_thin_pool *thin_pool_status = NULL;
 	struct lv_status_cache *cache_status = NULL;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7fc20b2fc..e96a04a69 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7580,7 +7580,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *tmp_lv;
 	const struct logical_volume *lock_lv;
-	struct lv_segment *seg, *pool_seg;
+	struct lv_segment *seg = NULL, *pool_seg;
 	int thin_pool_was_active = -1; /* not scanned, inactive, active */
 	int historical;
 	uint64_t transaction_id;


