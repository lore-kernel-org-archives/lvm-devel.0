From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 31 Mar 2016 10:22:18 +0000 (UTC)
Subject: master - cleanup: use local var to read struct
Message-ID: <20160331102218.122D660DEB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5034bb8d180a496fc24cd0ac0d8dde2332d28bc2
Commit:        5034bb8d180a496fc24cd0ac0d8dde2332d28bc2
Parent:        b10253ab4d932565dc69e5b3b6715177bb593ba8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 30 10:16:09 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 31 12:21:40 2016 +0200

cleanup: use local var to read struct

---
 lib/activate/dev_manager.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index de07f96..5341b54 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1332,10 +1332,10 @@ int dev_manager_cache_status(struct dev_manager *dm,
 	 * ->target_percent() API is able to transfer only a single value.
 	 * Needs to be able to pass whole structure.
 	 */
-	if (!dm_get_status_cache(dm->mem, params, &((*status)->cache)))
+	if (!dm_get_status_cache(dm->mem, params, &c))
 		goto_out;
 
-	c = (*status)->cache;
+	(*status)->cache = c;
 	(*status)->mem = dm->mem; /* User has to destroy this mem pool later */
 	if (c->fail || c->error) {
 		(*status)->data_usage =


