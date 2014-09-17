From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 17 Sep 2014 03:20:20 +0000 (UTC)
Subject: master - cache-pool: Fix specification of cachemode when converting to cache-pool
Message-ID: <20140917032020.645E261182@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d57aa9a0fe00322cb188ad1f3103d57392546e7
Commit:        9d57aa9a0fe00322cb188ad1f3103d57392546e7
Parent:        b87a7683e23c2c309f11929a488230570daf0dc0
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 16 22:19:53 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 16 22:19:53 2014 -0500

cache-pool:  Fix specification of cachemode when converting to cache-pool

Failure to copy the 'feature_flags' lvconvert_param to the matching
lv_segment field meant that when a user specified the cachemode argument,
the request was not honored.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6c12186..1015835 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Fix inablility to specify cachemode when 'lvconvert'ing to cache-pool.
   Disable vgchange of clustered attribute with any active LV in VG.
   Use va_copy to properly pass va_list through functions.
   Add function to detect rotational devices.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c7eb02d..93a2be4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2925,6 +2925,7 @@ mda_write:
 	seg->chunk_size = lp->chunk_size;
 	seg->discards = lp->discards;
 	seg->zero_new_blocks = lp->zero ? 1 : 0;
+	seg->feature_flags = lp->feature_flags; /* cache-pool */
 
 	/* Rename deactivated metadata LV to have _tmeta suffix */
 	/* Implicit checks if metadata_lv is visible */


