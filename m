From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Feb 2016 15:50:20 +0000 (UTC)
Subject: master - thin: report PERCENT_INVALID for failed pool
Message-ID: <20160218155020.C7CC260C98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0358ca3aadaddd8ed60c817abb67ea38bf07a420
Commit:        0358ca3aadaddd8ed60c817abb67ea38bf07a420
Parent:        0fb3669d49040ea2e616491326eecad9926048c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 18 13:18:18 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 18 16:45:42 2016 +0100

thin: report PERCENT_INVALID for failed pool

When thin-pool is in failed/error state, we can't
read percentage so report invalid value.
---
 WHATS_NEW       |    1 +
 lib/thin/thin.c |    8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bf3fc07..27bb7e2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.143 -
 =====================================
+  For failing thin-pool and thin volume correctly report percentage as INVALID.
   Report -1, not 'unkown' for lv_{snapshot_invalid,merge_failed} with --binary.
   Add configure --enable-dbus-service for an LVM D-Bus service.
   Replace configure --enable-python_bindings with python2 and python3 versions.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index c9ee9f5..221ac48 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -404,8 +404,10 @@ static int _thin_pool_target_percent(void **target_state __attribute__((unused))
 	if (!dm_get_status_thin_pool(mem, params, &s))
 		return_0;
 
+	if (s->fail || s->error)
+		*percent = DM_PERCENT_INVALID;
 	/* With 'seg' report metadata percent, otherwice data percent */
-	if (seg) {
+	else if (seg) {
 		*percent = dm_make_percent(s->used_metadata_blocks,
 					   s->total_metadata_blocks);
 		*total_numerator += s->used_metadata_blocks;
@@ -622,7 +624,9 @@ static int _thin_target_percent(void **target_state __attribute__((unused)),
 	if (!dm_get_status_thin(mem, params, &s))
 		return_0;
 
-	if (seg) {
+	if (s->fail)
+		*percent = DM_PERCENT_INVALID;
+	else if (seg) {
 		/* Pool allocates whole chunk so round-up to nearest one */
 		csize = first_seg(seg->pool_lv)->chunk_size;
 		csize = ((seg->lv->size + csize - 1) / csize) * csize;


