From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 19:00:33 -0400
Subject: master - allocation: add check for passing log allocation
Message-ID: <201807082300.w68N0XXl019174@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9d1f676b3768844471f8c6d3345a1b60bc2c94e
Commit:        e9d1f676b3768844471f8c6d3345a1b60bc2c94e
Parent:        333eb8667e73439c71dc351a02612c1c7601e8ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 00:54:16 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:59:34 2018 +0200

allocation: add check for passing log allocation

Updates previous commit.
---
 lib/metadata/lv_manip.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7674a3e..6bf851e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2966,7 +2966,9 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
 		       (*(alloc_state->areas + alloc_state->num_positional_areas + ix - 1 -
 			  too_small_for_log_count)).used < ah->log_len)
 			too_small_for_log_count++;
-		if (ah->mirror_logs_separate && (too_small_for_log_count >= devices_needed))
+		if (ah->mirror_logs_separate &&
+		    too_small_for_log_count &&
+		    (too_small_for_log_count >= devices_needed))
 			return 1;
 		if ((alloc_state->num_positional_areas + ix) < (too_small_for_log_count + ah->log_area_count))
 			return 1;


