From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 23 Oct 2017 06:07:17 -0400
Subject: master - lvextend: detect stacked cache lv used for thinpool
Message-ID: <201710231007.v9NA7HVU003923@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6fcab900b5b33c55c7894c3f4a7cdd1dbb81c1a
Commit:        d6fcab900b5b33c55c7894c3f4a7cdd1dbb81c1a
Parent:        de58df390b6bd3f46841fdacb9a75defccf9f3e2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 23 11:20:32 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 23 12:00:43 2017 +0200

lvextend: detect stacked cache lv used for thinpool

Ensure, that cacheLV is not tried to be resize until full support is
added.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2644d37..2f08468 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Avoid internal error when resizing cache type _tdata LV (not yet supported).
   Show original converted names when lvconverting LV to pool volume.
   Move lib code used only by liblvm into metadata-liblvm.c.
   Distinguish between device not found and excluded by filter.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c0e9a99..b03f9cf 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4797,7 +4797,8 @@ static int _lvresize_check(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (lv_is_cache_type(lv)) {
+	if (lv_is_cache_type(lv) ||
+	    (lv_is_thin_pool(lv) && lv_is_cache_type(seg_lv(first_seg(lv), 0)))) {
 		log_error("Unable to resize logical volumes of cache type.");
 		return 0;
 	}


