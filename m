From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 Feb 2013 18:08:13 +0000 (UTC)
Subject: master - cleanup: comment update
Message-ID: <20130204180813.E02793523@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=153ce89af36e716ace78182d8fe0668a6e98053d
Commit:        153ce89af36e716ace78182d8fe0668a6e98053d
Parent:        b37a0a39e3c80abdab2c3dc4522411c7aa9eec5e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 25 15:29:42 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 4 19:05:43 2013 +0100

cleanup: comment update

Just update code comment and use single line if().
---
 lib/metadata/lv_manip.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c1437eb..50e42dc 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -273,7 +273,7 @@ struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 	dm_list_init(&seg->thin_messages);
 
 	if (thin_pool_lv) {
-		/* If this thin volume, thin snapshot is being created */
+		/* If this is thin volume, thin snapshot is being created */
 		if (lv_is_thin_volume(thin_pool_lv)) {
 			seg->transaction_id = first_seg(first_seg(thin_pool_lv)->pool_lv)->transaction_id;
 			if (!attach_pool_lv(seg, first_seg(thin_pool_lv)->pool_lv, thin_pool_lv))
@@ -565,10 +565,8 @@ static int _lv_reduce(struct logical_volume *lv, uint32_t extents, int delete)
 			if (seg->metadata_lv && !lv_remove(seg->metadata_lv))
 				return_0;
 
-			if (seg->pool_lv) {
-				if (!detach_pool_lv(seg))
-					return_0;
-			}
+			if (seg->pool_lv && !detach_pool_lv(seg))
+				return_0;
 
 			dm_list_del(&seg->list);
 			reduction = seg->len;


