From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:35 +0000 (UTC)
Subject: master - thin: fix low_water_mark threshold calc
Message-ID: <20160211173935.89E8D60DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=02f2916b5be3f2f1dfdb9d1a76c753e46f1e480f
Commit:        02f2916b5be3f2f1dfdb9d1a76c753e46f1e480f
Parent:        8423be80eea3af40355edbdb1e14eed5cd3000a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 11 18:05:36 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:30:24 2016 +0100

thin: fix low_water_mark threshold calc

Reporter noticed lvm2 incorrectly translated
lvm2 threshold value to  water mark in commit:
99237f0908d87592815f4bdf3c239e8a108e835c

Fix it by properly translating size to number of
blocks in thin-pool and then calc for free blocks
matching configured lvm2 threshold value.

Reported-by: Ming-Hung Tsai <mingnus@gmail.com>
---
 WHATS_NEW       |    1 +
 lib/thin/thin.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6ae8126..002217d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.142 - 
 ====================================
+  Fix thinp watermark calc for data LV for faster dmeventd responce (2.02.133).
   Use use_blkid_wiping=0 if not defined in lvm.conf and support not compiled in.
   Do not check for suspended devices if scanning for lvmetad update.
   Fix part. table filter with external_device_info_source="udev" and blkid<2.20.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 9fbad32..c9ee9f5 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -295,9 +295,10 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	if (threshold < 50)
 		threshold = 50;
 	if (threshold < 100)
-		low_water_mark = (len * threshold + 99) / 100;
+		/* Translate to number of free pool blocks to trigger watermark */
+		low_water_mark = len / seg->chunk_size * (100 - threshold) / 100;
 	else
-		low_water_mark = len;
+		low_water_mark = 0;
 
 	if (!dm_tree_node_add_thin_pool_target(node, len,
 					       seg->transaction_id,


