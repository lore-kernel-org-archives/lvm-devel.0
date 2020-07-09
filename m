From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu,  9 Jul 2020 12:40:11 +0000 (GMT)
Subject: master - lvconvert: fix conversion to 'mirrored' mirror log with larger regionsize
Message-ID: <20200709124011.9126C384407D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=286a793c12aac1fde17cb9768bacad660e1dfeb3
Commit:        286a793c12aac1fde17cb9768bacad660e1dfeb3
Parent:        d0faad0db38fe733cae42d7df136d7ed4f7bcba6
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 9 14:09:46 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jul 9 14:39:50 2020 +0200

lvconvert: fix conversion to 'mirrored' mirror log with larger regionsize

merge.c:_check_lv_segment() was checking regionsize vs. mirrored LV size on
any 'mirror/raid1/raid10' segment type including type 'mirrored' mirror logs.

Avoid the check only for 'mirrored' mirror logs to allow conversion from log
type 'disk' with regionsize > mirror log SubLV size.

As we disabled support for 'mirrored' mirror logs with
commit e82303fd6abc3ae43168f8032806c7c17d181a3e which still conditionally
allows to enable it via global/support_mirrored_mirror_logs=1,
patch is mandatory for all distributions.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1712983
---
 WHATS_NEW            | 1 +
 lib/metadata/merge.c | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e2e6d919..89656a341 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.10 - 
 =================================
+  Fix conversion to 'mirrored' mirror log with larger regionsize.
   Zero pool metadata on allocation (disable with allocation/zero_metadata=0).
   Failure in zeroing or wiping will fail command (bypass with -Zn, -Wn).
   Fix running out of free buffers for async writing for larger writes.
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index ecd55efdd..1d47449db 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -441,7 +441,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 		if (seg_is_mirror(seg)) {
 			if (!seg->region_size)
 				seg_error("region size is zero");
-			else if (seg->region_size > seg->lv->size)
+			/* Avoid regionsize check in case of 'mirrored' mirror log or larger than mlog regionsize will fail */
+			else if (!strstr(seg->lv->name, "_mlog") && (seg->region_size > seg->lv->size))
 				seg_error("region size is bigger then LV itself");
 			else if (!is_power_of_2(seg->region_size))
 				seg_error("region size is non power of 2");


