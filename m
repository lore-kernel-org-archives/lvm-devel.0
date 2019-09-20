From: David Teigland <teigland@sourceware.org>
Date: Fri, 20 Sep 2019 11:00:42 -0400
Subject: master - lvconvert: cachevol LV can have multiple segments
Message-ID: <201909201500.x8KF0g6U018810@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2c065789cfac0ebfc5b6f3d85d9b2ce84d90e55
Commit:        d2c065789cfac0ebfc5b6f3d85d9b2ce84d90e55
Parent:        3ce0dc59f26ef22d38ffc6e26aa354ef8727ea19
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 18 15:11:14 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 20 09:59:37 2019 -0500

lvconvert: cachevol LV can have multiple segments

---
 lib/metadata/merge.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 08f8fbe..e482921 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -805,7 +805,6 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		if ((seg_count != 1) &&
 		    (lv_is_cache(lv) ||
 		     lv_is_cache_pool(lv) ||
-		     lv_is_cache_vol(lv) ||
 		     lv_is_raid(lv) ||
 		     lv_is_snapshot(lv) ||
 		     lv_is_thin_pool(lv) ||


