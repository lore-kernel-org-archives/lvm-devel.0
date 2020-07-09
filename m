From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu,  9 Jul 2020 12:44:07 +0000 (GMT)
Subject: stable-2.02 - lvconvert: fix conversion to 'mirrored' mirror log with larger regionsize
Message-ID: <20200709124407.BEC31384404C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ebe1bc901c3ed9404f92c7415c7c491593aed47
Commit:        7ebe1bc901c3ed9404f92c7415c7c491593aed47
Parent:        e7e2288ff4ac34d825dd13dd45b0418723a7da84
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Jul 9 14:09:46 2020 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Jul 9 14:43:23 2020 +0200

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
index 0e65ff172..846510b28 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Fix conversion to 'mirrored' mirror log with larger regionsize.
   Fix support for lvconvert --repair used by foreign apps (i.e. Docker).
 
 Version 2.02.187 - 24th March 2020
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index a024877a3..054f1855f 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -424,7 +424,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 		if (seg_is_mirror(seg)) {
 			if (!seg->region_size)
 				seg_error("region size is zero");
-			else if (seg->region_size > seg->lv->size)
+			/* Avoid regionsize check in case of 'mirrored' mirror log or larger than mlog regionsize will fail */
+			else if (!strstr(seg->lv->name, "_mlog") && (seg->region_size > seg->lv->size))
 				seg_error("region size is bigger then LV itself");
 			else if (!is_power_of_2(seg->region_size))
 				seg_error("region size is non power of 2");


