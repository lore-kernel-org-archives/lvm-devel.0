From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 17 Jun 2013 18:13:29 +0000 (UTC)
Subject: master - RAID: s/int/uint32_t for dev_count in dm_status_raid struct
Message-ID: <20130617181329.38CCE61126@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ac9791c362dd150abb80749fbb72c4a336fc61b
Commit:        8ac9791c362dd150abb80749fbb72c4a336fc61b
Parent:        7a4fdc19022e578c6003b6bdbd9e5edfa753a827
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jun 17 12:58:38 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jun 17 12:58:38 2013 -0500

RAID:  s/int/uint32_t for dev_count in dm_status_raid struct

Device count is never negative.  Change 'dev_count' to be
uint32_t instead of int.
---
 libdm/libdevmapper.h  |    2 +-
 libdm/libdm-deptree.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index bada775..0434506 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -281,7 +281,7 @@ struct dm_status_raid {
 	uint64_t total_regions;
 	uint64_t insync_regions;
 	uint64_t mismatch_count;
-	int dev_count;
+	uint32_t dev_count;
 	char *raid_type;
 	char *dev_health;
 	char *sync_action;
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 50ed908..ba415b2 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2978,7 +2978,7 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 	if (!(s->dev_health = dm_pool_zalloc(mem, i + 1)))
 		goto_bad;
 
-	if (sscanf(params, "%s %d %s %" PRIu64 "/%" PRIu64,
+	if (sscanf(params, "%s %u %s %" PRIu64 "/%" PRIu64,
 		   s->raid_type,
 		   &s->dev_count,
 		   s->dev_health,


