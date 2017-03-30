From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:33:16 -0400
Subject: master - libdm: fix incorrect format specifier in _stats_resize_group()
Message-ID: <201703300933.v2U9XGef023021@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e8d5e05ff57a327053f140f2fed4c12f8fe7e076
Commit:        e8d5e05ff57a327053f140f2fed4c12f8fe7e076
Parent:        b8b2b1efd84fb1e96500d86f2ada3c2efa1338f3
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 30 10:31:36 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:31:36 2017 +0100

libdm: fix incorrect format specifier in _stats_resize_group()

The bitmap size in dm_bitset_t[0] is a uint32_t, not uint64_t: use
%u instead of FMTu64.
---
 libdm/libdm-stats.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index b69302f..78aa566 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4193,9 +4193,9 @@ static int _stats_resize_group(struct dm_stats_group *group,
 		return 0;
 	}
 
-	log_very_verbose("Resizing group bitmap from " FMTu64
-			 " to " FMTu64 " (last_bit: " FMTu64 ").",
-			 group->regions[0], num_regions, last_bit);
+	log_very_verbose("Resizing group bitmap from %u to " FMTu64
+			 " (last_bit: " FMTu64 ").", group->regions[0],
+			 num_regions, last_bit);
 
 	new = dm_bitset_create(NULL, (unsigned) num_regions);
 	if (!new) {


