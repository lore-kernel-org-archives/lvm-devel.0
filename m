From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:33:03 +0000 (UTC)
Subject: master - thin: no validation skip of new thin pools
Message-ID: <20141104143303.E8F24608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee627884de95ae5a40f0fc2534dcd60e63e2a58d
Commit:        ee627884de95ae5a40f0fc2534dcd60e63e2a58d
Parent:        26aa912b4663633c6e094bad85393601903bcaac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 09:51:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:28:00 2014 +0100

thin: no validation skip of new thin pools

Allowing 'external' use of thin-pools requires to validate even
so far 'unused' new thin pools.

Later we may have 'smarter' way to resolve which thin-pools are
owned by lvm2 and which are external.
---
 lib/activate/dev_manager.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 266c80a..41911c1 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1815,12 +1815,15 @@ static int _pool_register_callback(struct dev_manager *dm,
 {
 	struct pool_cb_data *data;
 
+	/* Do not skip metadata of testing even for unused thin pools */
+#if 0
 	/* Skip metadata testing for unused thin pool. */
 	if (lv_is_thin_pool(lv) &&
 	    (!first_seg(lv)->transaction_id ||
 	     ((first_seg(lv)->transaction_id == 1) &&
 	      pool_has_message(first_seg(lv), NULL, 0))))
 		return 1;
+#endif
 
 	if (!(data = dm_pool_zalloc(dm->mem, sizeof(*data)))) {
 		log_error("Failed to allocated path for callback.");


