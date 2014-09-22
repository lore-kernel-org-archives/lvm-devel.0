From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:23 +0000 (UTC)
Subject: dev-dct-process-latest - dev-cache: Filter wipe does not guarantee a full /dev scan.
Message-ID: <20140922153723.BB0FA6153C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f0c4c811da287e7fc28b8c31dcd03347b16d360
Commit:        1f0c4c811da287e7fc28b8c31dcd03347b16d360
Parent:        47ff145e08f689306762840efd72e8a4e1c91214
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 9 17:14:35 2014 +0200
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 10 22:57:49 2014 +0100

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


