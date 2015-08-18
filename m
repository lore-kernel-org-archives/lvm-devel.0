From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:34 +0000 (UTC)
Subject: master - libdm: simplify dmstats formula.
Message-ID: <20150818130134.D2FEB60643@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba94d0f144844ff3fb15d0a2a87ccf7f27f550bc
Commit:        ba94d0f144844ff3fb15d0a2a87ccf7f27f550bc
Parent:        ae4db9f302701ccbde1409647a85f53feaa6e13b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 12:12:07 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:08 2015 +0200

libdm: simplify dmstats formula.

Since we check for stats for not being 0,
simplify the operation and use a single division.
---
 libdm/libdm-stats.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index ba213b7..f231016 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -510,11 +510,10 @@ static uint64_t _nr_areas(uint64_t len, uint64_t step)
 	/*
 	 * drivers/md/dm-stats.c::message_stats_create()
 	 * A region may be sub-divided into areas with their own counters.
-	 * If step is non-zero, divide len into that many areas, otherwise
-	 * treat the entire region as a single area. Any partial area at the
-	 * end of the region is treated as an additional complete area.
+	 * Any partial area at the end of the region is treated as an
+	 * additional complete area.
 	 */
-	return (len / (step ? : len)) + !!(len % step);
+	return (len + step - 1) / step;
 }
 
 static uint64_t _nr_areas_region(struct dm_stats_region *region)


