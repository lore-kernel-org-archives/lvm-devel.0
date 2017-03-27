From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Mar 2017 14:51:02 -0400
Subject: master - cleanup: use more common FMTd64 type
Message-ID: <201703271851.v2RIp2pC004592@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3a3cf01eb51cb528ecf6d90548f29a781510557
Commit:        e3a3cf01eb51cb528ecf6d90548f29a781510557
Parent:        78d004efa8a1809cea68283e6204edfa9d7c1091
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 27 20:32:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 27 20:50:19 2017 +0200

cleanup: use more common FMTd64 type

We use 'd' for plain singed integers.
---
 lib/cache/lvmetad.c |    2 +-
 libdm/libdm-stats.c |    6 +++---
 tools/dmsetup.c     |    2 +-
 tools/pvscan.c      |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index e67fe31..531e01c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -66,7 +66,7 @@ static int _log_debug_inequality(const char *name, struct dm_config_node *a, str
 					log_debug_lvmetad("VG %s metadata inequality at %s / %s: %s / %s",
 							  name, a->key, b->key, av->v.str, bv->v.str);
 				else if (a->v->type == DM_CFG_INT && b->v->type == DM_CFG_INT)
-					log_debug_lvmetad("VG %s metadata inequality at %s / %s: " FMTi64 " / " FMTi64,
+					log_debug_lvmetad("VG %s metadata inequality at %s / %s: " FMTd64 " / " FMTd64,
 							  name, a->key, b->key, av->v.i, bv->v.i);
 				else
 					log_debug_lvmetad("VG %s metadata inequality at %s / %s: type %d / type %d",
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index e977f08..fa865a1 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -680,8 +680,8 @@ static void _check_group_regions_present(struct dm_stats *dms,
 
 	for (; i > 0; i = dm_bit_get_next(regions, i))
 		if (!_stats_region_present(&dms->regions[i])) {
-			log_warn("Group descriptor " FMTi64 " contains "
-				 "non-existent region_id " FMTi64 ".",
+			log_warn("Group descriptor " FMTd64 " contains "
+				 "non-existent region_id " FMTd64 ".",
 				 group_id, i);
 			dm_bit_clear(regions, i);
 		}
@@ -4563,7 +4563,7 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 		log_error("Could not finalize region extent table.");
 		goto out;
 	}
-	log_very_verbose("Kept " FMTi64 " of " FMTi64 " old extents",
+	log_very_verbose("Kept " FMTd64 " of " FMTd64 " old extents",
 			 nr_kept, nr_old);
 	log_very_verbose("Found " FMTu64 " new extents",
 			 *count - nr_kept);
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 1e22cf1..94787dc 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -689,7 +689,7 @@ static int _do_usleep_wait(void)
 	} else {
 		dm_timestamp_get(_now);
 		delta_t = dm_timestamp_delta(_now, _start_timestamp);
-		log_debug("Interval timer drift: "FMTi64,
+		log_debug("Interval timer drift: "FMTd64,
 			  (delta_t % _interval));
 
 		/* FIXME: usleep timer drift over large counts. */
diff --git a/tools/pvscan.c b/tools/pvscan.c
index ca33a2a..6581990 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -130,7 +130,7 @@ static int _lvmetad_clear_dev(dev_t devno, int32_t major, int32_t minor)
 {
 	char buf[24];
 
-	(void) dm_snprintf(buf, sizeof(buf), FMTi32 ":" FMTi32, major, minor);
+	(void) dm_snprintf(buf, sizeof(buf), FMTd32 ":" FMTd32, major, minor);
 
 	if (!lvmetad_pv_gone(devno, buf))
 		return_0;


