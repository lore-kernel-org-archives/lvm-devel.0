From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  8 Oct 2012 14:18:57 +0000 (UTC)
Subject: master - dev-cache: Make dev_iter_create work with a NULL filter.
Message-ID: <20121008141857.45A6E9FBD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee4c75c8b790001cb05d85a44b2a894a91f4ba05
Commit:        ee4c75c8b790001cb05d85a44b2a894a91f4ba05
Parent:        3877ccfe1bdbd0d2690d7488fcea42fac53fcb50
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 8 16:16:58 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 8 16:18:10 2012 +0200

dev-cache: Make dev_iter_create work with a NULL filter.

---
 lib/device/dev-cache.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 79b3028..44a9e27 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -971,8 +971,12 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 
 	if (dev_scan && !trust_cache()) {
 		/* Flag gets reset between each command */
-		if (!full_scan_done() && f && f->wipe)
-			f->wipe(f); /* Calls _full_scan(1) */
+		if (!full_scan_done()) {
+			if (f && f->wipe)
+				f->wipe(f); /* Calls _full_scan(1) */
+			else
+				_full_scan(1);
+		}
 	} else
 		_full_scan(0);
 


