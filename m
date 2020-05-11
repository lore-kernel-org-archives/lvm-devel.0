From: David Teigland <teigland@sourceware.org>
Date: Mon, 11 May 2020 18:15:47 +0000 (GMT)
Subject: master - lvmlockd: use 4K sector size when any dev is 4K
Message-ID: <20200511181547.1E224388F057@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d1fe38d84d499011d13ae1ea11535398528fc87
Commit:        2d1fe38d84d499011d13ae1ea11535398528fc87
Parent:        33265467f9c1cf701293fdf8921f6d92eb7d11d9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon May 11 13:08:39 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 11 13:14:55 2020 -0500

lvmlockd: use 4K sector size when any dev is 4K

When either logical block size or physical block size is 4K,
then lvmlockd creates sanlock leases based on 4K sectors,
but the lvm client side would create the internal lvmlock LV
based on the first logical block size it saw in the VG,
which could be 512.  This could cause the lvmlock LV to be
too small to hold all the sanlock leases. Make the lvm client
side use the same sizing logic as lvmlockd.
---
 lib/locking/lvmlockd.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e378fe6cb..dca7954ab 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -635,7 +635,6 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	const char *vg_lock_args = NULL;
 	const char *opts = NULL;
 	struct pv_list *pvl;
-	struct device *sector_dev;
 	uint32_t sector_size = 0;
 	unsigned int physical_block_size, logical_block_size;
 	int num_mb = 0;
@@ -656,16 +655,11 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (!dev_get_direct_block_sizes(pvl->pv->dev, &physical_block_size, &logical_block_size))
 			continue;
-
-		if (!sector_size) {
-			sector_size = logical_block_size;
-			sector_dev = pvl->pv->dev;
-		} else if (sector_size != logical_block_size) {
-			log_error("Inconsistent logical block sizes for %s and %s.",
-				  dev_name(pvl->pv->dev), dev_name(sector_dev));
-			return 0;
-		}
+		if ((physical_block_size == 4096) || (logical_block_size == 4096))
+			sector_size = 4096;
 	}
+	if (!sector_size)
+		sector_size = 512;
 
 	log_debug("Using sector size %u for sanlock LV", sector_size);
 


