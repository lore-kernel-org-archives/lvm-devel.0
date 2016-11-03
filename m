From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Nov 2016 16:49:53 +0000 (UTC)
Subject: master - cleanup: use WARNING prefix for log_warn
Message-ID: <20161103164953.9AC5360910@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e26024add915a1970eb7f43298b24b180e7e061
Commit:        4e26024add915a1970eb7f43298b24b180e7e061
Parent:        0d95082aa97b92d120daf1858acd91abe788d2cb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 26 14:42:13 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 3 17:49:07 2016 +0100

cleanup: use WARNING prefix for log_warn

Use capital WARNING prefix for log_warn() messages.
---
 libdm/libdm-stats.c |    8 ++++----
 tools/dmsetup.c     |    2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 73d7ae8..55e2a42 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3881,7 +3881,7 @@ merge:
 			continue;
 
 		if (_extents_overlap(ext, next)) {
-			log_warn("Warning: region IDs " FMTu64 " and "
+			log_warn("WARNING: region IDs " FMTu64 " and "
 				 FMTu64 " overlap. Some events will be "
 				 "counted twice.", ext->id, next->id);
 			/* merge larger extent into smaller */
@@ -4002,8 +4002,8 @@ int dm_stats_create_group(struct dm_stats *dms, const char *members,
 	}
 
 	if (precise && (precise != count))
-		log_warn("Grouping regions with different clock resolution: "
-			 "precision may be lost");
+		log_warn("WARNING: Grouping regions with different clock resolution: "
+			 "precision may be lost.");
 
 	if (!_stats_group_check_overlap(dms, regions, count))
 		log_very_verbose("Creating group with overlapping regions.");
@@ -4048,7 +4048,7 @@ int dm_stats_delete_group(struct dm_stats *dms, uint64_t group_id,
 		if (dm_bit(regions, i)) {
 			dm_bit_clear(regions, i);
 			if (remove_regions && !dm_stats_delete_region(dms, i))
-				log_warn("Failed to delete region "
+				log_warn("WARNING: Failed to delete region "
 					 FMTu64 " on %s.", i, dms->name);
 		}
 	}
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 42f0b05..4b525e2 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1611,7 +1611,7 @@ static int _udevcomplete_all(CMD_ARGS)
 	}
 
 	if (!_switches[YES_ARG]) {
-		log_warn("This operation will destroy all semaphores %s%.0d%swith keys "
+		log_warn("WARNING: This operation will destroy all semaphores %s%.0d%swith keys "
 			 "that have a prefix %" PRIu16 " (0x%" PRIx16 ").",
 			 age ? "older than " : "", age, age ? " minutes " : "",
 			 DM_COOKIE_MAGIC, DM_COOKIE_MAGIC);


