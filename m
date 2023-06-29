From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2023 18:25:00 +0000 (GMT)
Subject: main - vdo: indent for lvdisplay
Message-ID: <20230629182500.5A1653858410@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e48c9826e3069b06a5aa31e1e59200dce4915983
Commit:        e48c9826e3069b06a5aa31e1e59200dce4915983
Parent:        6ff65e675582265a673136f1edd5358b26c9e481
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 11:53:29 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 13:10:42 2023 +0200

vdo: indent for lvdisplay

---
 lib/vdo/vdo.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/vdo/vdo.c b/lib/vdo/vdo.c
index 133678ae7..6d3b67421 100644
--- a/lib/vdo/vdo.c
+++ b/lib/vdo/vdo.c
@@ -173,7 +173,7 @@ static void _vdo_pool_display(const struct lv_segment *seg)
 		  display_size(cmd, vtp->minimum_io_size));
 	log_print("  Block map cache sz\t%s",
 		  display_size(cmd, vtp->block_map_cache_size_mb * UINT64_C(2 * 1024)));
-	log_print("  Block map era length\t%u", vtp->block_map_era_length);
+	log_print("  Block map era length %u", vtp->block_map_era_length);
 
 	_print_yes_no("Sparse index", vtp->use_sparse_index);
 
@@ -190,7 +190,7 @@ static void _vdo_pool_display(const struct lv_segment *seg)
 	log_print("  # Hash zone threads\t%u", (unsigned) vtp->hash_zone_threads);
 	log_print("  # Logical threads\t%u", (unsigned) vtp->logical_threads);
 	log_print("  # Physical threads\t%u", (unsigned) vtp->physical_threads);
-	log_print("  Max discard\t%u", (unsigned) vtp->max_discard);
+	log_print("  Max discard\t\t%u", (unsigned) vtp->max_discard);
 	log_print("  Write policy\t%s", get_vdo_write_policy_name(vtp->write_policy));
 }
 

