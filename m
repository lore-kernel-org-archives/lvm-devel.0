From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:33:01 +0000 (UTC)
Subject: master - thin: add lv_is_new_thin_pool
Message-ID: <20141104143301.D2D69608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=26aa912b4663633c6e094bad85393601903bcaac
Commit:        26aa912b4663633c6e094bad85393601903bcaac
Parent:        89233544e00a0acfad82055b737ebcce41919d58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 10:31:28 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:28:00 2014 +0100

thin: add lv_is_new_thin_pool

Recognize 'new' (and never used) lvm2 thin pool - it has 'transaction_id' == 0
(lv_is_used_thin_pool() has slightly different meaning).
---
 lib/metadata/metadata-exported.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 736b0b5..713b3b6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -175,6 +175,7 @@
 
 #define lv_is_thin_volume(lv)	(((lv)->status & THIN_VOLUME) ? 1 : 0)
 #define lv_is_thin_pool(lv)	(((lv)->status & THIN_POOL) ? 1 : 0)
+#define lv_is_new_thin_pool(lv)	(lv_is_thin_pool(lv) && !first_seg(lv)->transaction_id)
 #define lv_is_used_thin_pool(lv)	(lv_is_thin_pool(lv) && !dm_list_empty(&(lv)->segs_using_this_lv))
 #define lv_is_thin_pool_data(lv)	(((lv)->status & THIN_POOL_DATA) ? 1 : 0)
 #define lv_is_thin_pool_metadata(lv)	(((lv)->status & THIN_POOL_METADATA) ? 1 : 0)


