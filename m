From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 16 Sep 2016 01:13:40 +0000 (UTC)
Subject: master - alloc: Use --alloc normal for mirror logs.
Message-ID: <20160916011340.EADBA607AF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c8c8fb63abd1a36b9c448450c9cccfac4c0299e
Commit:        9c8c8fb63abd1a36b9c448450c9cccfac4c0299e
Parent:        5da35d879ad073d9fb0d7ec8bfabe9ae39ac5bc1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Sep 16 02:11:58 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Sep 16 02:11:58 2016 +0100

alloc: Use --alloc normal for mirror logs.

The existing code doesn't understand that mirror logs should cling to
parallel LVs (like extending them) instead of avoiding them.

As a quick workaround to avoid lvcreate failures, hard-code
--alloc normal for mirror logs even if the rest of the allocation
used a stricter policy.

https://bugzilla.redhat.com/show_bug.cgi?id=1376532
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1ef3dc6..9c6ba3b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Use --alloc normal for mirror logs even if the mimages were stricter.
   Use O_DIRECT to gather metadata in lvmdump.
   Fix possible NULL pointer derefence when checking for monitoring.
   Add lvmreport(7) man page.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index dcc8d86..d6869e1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3085,6 +3085,15 @@ static int _allocate(struct alloc_handle *ah,
 		if (!_find_max_parallel_space_for_one_policy(ah, &alloc_parms, pvms, &alloc_state))
 			goto_out;
 
+		/* As a workaround, if only the log is missing now, fall through and try later policies up to normal. */
+		/* FIXME Change the core algorithm so the log extents cling to parallel LVs instead of avoiding them. */
+		if (alloc_state.allocated == ah->new_extents &&
+		    alloc_state.log_area_count_still_needed &&
+		    ah->alloc < ALLOC_NORMAL) {
+			ah->alloc = ALLOC_NORMAL;
+			continue;
+		}
+
 		if ((alloc_state.allocated == ah->new_extents &&
 		     !alloc_state.log_area_count_still_needed) ||
 		    (!can_split && (alloc_state.allocated != old_allocated)))


