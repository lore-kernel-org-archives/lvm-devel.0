From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 17 Aug 2015 13:41:59 +0000 (UTC)
Subject: master - libdm: ensure dm_stats_get_area_offset() returns a value
Message-ID: <20150817134159.7532B60095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=427d0a5e925d86145df12313aa36d5c61ff59bd5
Commit:        427d0a5e925d86145df12313aa36d5c61ff59bd5
Parent:        623b46a17d4163b42f9f65c41d5c8d8f95ec95c5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 13:56:44 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 17 14:40:48 2015 +0100

libdm: ensure dm_stats_get_area_offset() returns a value

---
 libdm/libdm-stats.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 400b12d..50492f3 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1341,6 +1341,7 @@ uint64_t dm_stats_get_area_offset(const struct dm_stats *dms, uint64_t *offset,
 	if (!dms || !dms->regions)
 		return_0;
 	*offset = dms->regions[region_id].step * area_id;
+	return 1;
 }
 
 uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,


