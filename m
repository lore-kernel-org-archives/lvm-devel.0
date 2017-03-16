From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Mar 2017 20:02:38 -0400
Subject: master - libdm: fix endless loop
Message-ID: <201703160002.v2G02c34017652@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=42b970d4f34a0cf70ac07d551852cbd7b924079f
Commit:        42b970d4f34a0cf70ac07d551852cbd7b924079f
Parent:        2a139993b40c4497536a2a0b6d826c73213b332d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 00:36:06 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 01:02:10 2017 +0100

libdm: fix endless loop

Coverity noticed endless loop (i not being changed).

TODO: test coverage
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 559920e..e977f08 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -678,7 +678,7 @@ static void _check_group_regions_present(struct dm_stats *dms,
 
 	group_id = i = dm_bit_get_first(regions);
 
-	for (; i > 0; dm_bit_get_next(regions, i))
+	for (; i > 0; i = dm_bit_get_next(regions, i))
 		if (!_stats_region_present(&dms->regions[i])) {
 			log_warn("Group descriptor " FMTi64 " contains "
 				 "non-existent region_id " FMTi64 ".",


