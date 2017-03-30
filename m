From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 11:31:52 -0400
Subject: master - libdm: use correct FMTu32 format specifier for uint32_t
Message-ID: <201703301531.v2UFVqmt006481@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=febda60f3daf8d9e0ff47aa692a90fe4ed36c128
Commit:        febda60f3daf8d9e0ff47aa692a90fe4ed36c128
Parent:        e8d5e05ff57a327053f140f2fed4c12f8fe7e076
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 30 16:17:19 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 16:17:19 2017 +0100

libdm: use correct FMTu32 format specifier for uint32_t

---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 78aa566..6ce6c57 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4193,7 +4193,7 @@ static int _stats_resize_group(struct dm_stats_group *group,
 		return 0;
 	}
 
-	log_very_verbose("Resizing group bitmap from %u to " FMTu64
+	log_very_verbose("Resizing group bitmap from " FMTu32 " to " FMTu64
 			 " (last_bit: " FMTu64 ").", group->regions[0],
 			 num_regions, last_bit);
 


