From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 25 Sep 2013 02:32:19 +0000 (UTC)
Subject: master - RAID: Fix broken allocation policies for parity RAID types
Message-ID: <20130925023219.150E860FE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ded7314ae00629da8d21d925c3fa091cce2a939
Commit:        5ded7314ae00629da8d21d925c3fa091cce2a939
Parent:        6553f86818404cd34fa3600dc976ed25fcf6d65a
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 24 21:32:10 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 24 21:32:10 2013 -0500

RAID: Fix broken allocation policies for parity RAID types

A previous commit (b6bfddcd0a830d0c9312bc3ab906cb3d1b7a6dd9) which
was designed to prevent segfaults during lvextend when trying to
extend striped logical volumes forgot to include calculations for
RAID4/5/6 parity devices.  This was causing the 'contiguous' and
'cling_by_tags' allocation policies to fail for RAID 4/5/6.

The solution is to remember that while we can compare
	ah->area_count == prev_lvseg->area_count
for non-RAID, we should compare
	(ah->area_count + ah->parity_count) == prev_lvseg->area_count
for a general solution.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1aebdf4..8a50122 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)
   Set use_lvmetad=0 on lvmconf --enable-cluster, reset to default on --disable-cluster.
   Don't install separate command symlink in binary directory for 'lvm devtypes'.
   Add seg_size_pe field to reports.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a145c41..c16288e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1200,7 +1200,8 @@ static void _init_alloc_parms(struct alloc_handle *ah, struct alloc_parms *alloc
 	alloc_parms->extents_still_needed = extents_still_needed;
 
 	/* Only attempt contiguous/cling allocation to previous segment areas if the number of areas matches. */
-	if (alloc_parms->prev_lvseg && (ah->area_count == prev_lvseg->area_count))
+	if (alloc_parms->prev_lvseg &&
+	    ((ah->area_count + ah->parity_count) == prev_lvseg->area_count))
 		alloc_parms->flags |= A_AREA_COUNT_MATCHES;
 
 	/* Are there any preceding segments we must follow on from? */


