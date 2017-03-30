From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:03:57 -0400
Subject: master - libdm: use DM_STATS_GROUP_* constants in dm_stats_create_regions_from_fd
Message-ID: <201703300903.v2U93vE7019884@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac6089ee8dce83bd61d90344bf67aeef8f319f41
Commit:        ac6089ee8dce83bd61d90344bf67aeef8f319f41
Parent:        fe0922b8a6632456d9f20085f1c67d2ddb5b2d88
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:02:26 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 09:57:58 2017 +0100

libdm: use DM_STATS_GROUP_* constants in dm_stats_create_regions_from_fd

---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 290097f..b553da5 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4777,7 +4777,8 @@ uint64_t *dm_stats_create_regions_from_fd(struct dm_stats *dms, int fd,
 	}
 
 	if (!(regions = _stats_map_file_regions(dms, fd, bounds, precise,
-						-1, &count, &regroup)))
+						DM_STATS_GROUP_NOT_PRESENT,
+						&count, &regroup)))
 		return NULL;
 
 	if (!group)


