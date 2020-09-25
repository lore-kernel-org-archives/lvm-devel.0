From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:02 +0000 (GMT)
Subject: master - thin: no delete message for device_id 0
Message-ID: <20200925210702.A39B9385782E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2eb1dc501aca4b11997b31978c9ce62916a7c98
Commit:        e2eb1dc501aca4b11997b31978c9ce62916a7c98
Parent:        fc9e7328113fb3c1563909cce3abde329684c637
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 22:42:53 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:54:07 2020 +0200

thin: no delete message for device_id 0

Since we always use device_id > 0, we could use
device_id == 0 to actually mark thinLV as an
LV we want to remove without delete message.
---
 lib/metadata/pool_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 23b5b63ba..a9dc6116d 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -310,7 +310,8 @@ int detach_pool_lv(struct lv_segment *seg)
 	if (!detach_thin_external_origin(seg))
 		return_0;
 
-	if (!attach_pool_message(first_seg(seg->pool_lv),
+	if (seg->device_id && /* Only thins with device_id > 0 can be deleted */
+	    !attach_pool_message(first_seg(seg->pool_lv),
 				 DM_THIN_MESSAGE_DELETE,
 				 NULL, seg->device_id, no_update))
 		return_0;


