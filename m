From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 18:36:47 -0400
Subject: 2018-06-01-stable - allocator: fix thin-pool allocation
Message-ID: <201807082236.w68MalRb017099@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0851ee5301ca69bf7038f529d2335c93833db758
Commit:        0851ee5301ca69bf7038f529d2335c93833db758
Parent:        df8eef70961686c32e7409551d9c2633eb629fc9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 8 18:34:38 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:35:34 2018 +0200

allocator: fix thin-pool allocation

When allocating thin-pool with more then 1 device - try to
allocate 'metadataLV' with reuse of log-type allocation for mirror LV.
It should be naturally place on other device then 'dataLV'.

However due to somewhat hard to follow allocation logic code,
it's been rejected allocation in cases where there was not
enough space for data or metadata on single PV, thus to successed,
usage of segments was mandatory.

While user may use:

allocation/thin_pool_metadata_require_separate_pvs=1

to enforce separe meta and data LV - on default settings, this is not
enable thus segment allocation is meant to work.

NOTE:

As already said - the original intention of this whole  'if()' is unclear,
so try to split this test into multiple more simple tests that are more readable.

TODO: more validation.
---
 lib/metadata/lv_manip.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c5e63a9..e78f061 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2959,12 +2959,14 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		       (*(alloc_state->areas + alloc_state->num_positional_areas + ix - 1 -
 			  too_small_for_log_count)).used < ah->log_len)
 			too_small_for_log_count++;
-		ix_log_offset = alloc_state->num_positional_areas + ix - too_small_for_log_count - ah->log_area_count;
+		if (ah->mirror_logs_separate && (too_small_for_log_count >= devices_needed))
+			return 1;
+		if ((alloc_state->num_positional_areas + ix) < (too_small_for_log_count + ah->log_area_count))
+			return 1;
+		ix_log_offset = alloc_state->num_positional_areas + ix - (too_small_for_log_count + ah->log_area_count);
 	}
 
-	if (ix + alloc_state->num_positional_areas < devices_needed +
-	    (alloc_state->log_area_count_still_needed ? alloc_state->log_area_count_still_needed +
-				    too_small_for_log_count : 0))
+	if (ix + alloc_state->num_positional_areas < devices_needed)
 		return 1;
 
 	/*


