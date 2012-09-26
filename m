From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:35 +0000 (UTC)
Subject: master - dev-cache: Make it possible to pass in a NULL filter.
Message-ID: <20120926175535.55E73A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72d82e21d44c48a3823156afa900eb071b3eb144
Commit:        72d82e21d44c48a3823156afa900eb071b3eb144
Parent:        012d273ede86f0e3e894b0e907f7f623c3dda7e0
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 18 22:03:46 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 12:23:34 2012 +0200

dev-cache: Make it possible to pass in a NULL filter.

---
 lib/device/dev-cache.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index c92e11e..1da9a77 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -971,21 +971,23 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 
 	if (dev_scan && !trust_cache()) {
 		/* Flag gets reset between each command */
-		if (!full_scan_done())
+		if (!full_scan_done() && f)
 			persistent_filter_wipe(f); /* Calls _full_scan(1) */
 	} else
 		_full_scan(0);
 
 	di->current = btree_first(_cache.devices);
 	di->filter = f;
-	di->filter->use_count++;
+	if (di->filter)
+		di->filter->use_count++;
 
 	return di;
 }
 
 void dev_iter_destroy(struct dev_iter *iter)
 {
-	iter->filter->use_count--;
+	if (iter->filter)
+		iter->filter->use_count--;
 	dm_free(iter);
 }
 


