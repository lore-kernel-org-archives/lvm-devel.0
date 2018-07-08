From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 8 Jul 2018 18:59:08 -0400
Subject: 2018-06-01-stable - allocation: add check for passing log allocation
Message-ID: <201807082259.w68Mx8AV019147@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66990bc7c80059dff76faebd4c1d50254f3804b5
Commit:        66990bc7c80059dff76faebd4c1d50254f3804b5
Parent:        6fcb2ba440ebd40cdbe295b01dbbdea59ce9f895
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 00:54:16 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 00:58:30 2018 +0200

allocation: add check for passing log allocation

Updates previous commit.
---
 lib/metadata/lv_manip.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e78f061..e4293cc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2959,7 +2959,9 @@ static int _find_some_parallel_space(struct alloc_handle *ah,
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


