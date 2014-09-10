From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 10 Sep 2014 17:57:07 +0000 (UTC)
Subject: master - dev-cache: Filter wipe does not guarantee a full /dev scan.
Message-ID: <20140910175707.C035C60556@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66cce64e6985f7f1614c6bde618c7a4207fea7e9
Commit:        66cce64e6985f7f1614c6bde618c7a4207fea7e9
Parent:        c774d9a3f35c312d5b24c4ba13da707ccd975194
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 9 17:14:35 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Sep 9 17:14:35 2014 +0200

dev-cache: Filter wipe does not guarantee a full /dev scan.

The code in dev_iter_create assumes that if a filter can be wiped, doing so will
always trigger a call to _full_scan. This is not true for composite filters
though, since they can always be wiped in principle, but there is no way to know
that a component filter inside will exist that actually triggers the scan.
---
 lib/device/dev-cache.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 1d7a517..ba4ee54 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1009,9 +1009,11 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 	if (dev_scan && !trust_cache()) {
 		/* Flag gets reset between each command */
 		if (!full_scan_done()) {
-			if (f && f->wipe)
-				f->wipe(f); /* Calls _full_scan(1) */
-			else
+			if (f && f->wipe) {
+				f->wipe(f); /* might call _full_scan(1) */
+				if (!full_scan_done())
+					_full_scan(1);
+			} else
 				_full_scan(1);
 		}
 	} else


