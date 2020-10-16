From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:47 +0000 (GMT)
Subject: stable-2.02 - thin: no delete message for device_id 0
Message-ID: <20201016191147.71D30396EC92@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e8016ffa96490f040cab35b83c18ef92409b7b9
Commit:        9e8016ffa96490f040cab35b83c18ef92409b7b9
Parent:        5726b93709890ddc6f9f08a28ca1e835b2c05a3b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 22:42:53 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

thin: no delete message for device_id 0

Since we always use device_id > 0, we could use
device_id == 0 to actually mark thinLV as an
LV we want to remove without delete message.
---
 lib/metadata/pool_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index b832db747..1381f29bf 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -296,7 +296,8 @@ int detach_pool_lv(struct lv_segment *seg)
 	if (!detach_thin_external_origin(seg))
 		return_0;
 
-	if (!attach_pool_message(first_seg(seg->pool_lv),
+	if (seg->device_id && /* Only thins with device_id > 0 can be deleted */
+	    !attach_pool_message(first_seg(seg->pool_lv),
 				 DM_THIN_MESSAGE_DELETE,
 				 NULL, seg->device_id, no_update))
 		return_0;


