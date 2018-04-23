From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:54:09 -0400
Subject: master - scan: leave the caller's dev list unchanged
Message-ID: <201804231354.w3NDs9Nt001342@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f328532f05877fc04e7f67c751ef95a844831b9b
Commit:        f328532f05877fc04e7f67c751ef95a844831b9b
Parent:        7bce66c5e83296398e2eee99140b3d6e409236c9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 14 16:15:30 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

scan: leave the caller's dev list unchanged

When scanning the list of devs from the caller
they are moved to another temporary list, but
were never returned to the original list.
---
 lib/label/label.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index bf1070c..3359b4d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -567,6 +567,8 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	if (failed)
 		*failed = scan_failed_count;
 
+	dm_list_splice(devs, &done_devs);
+
 	return 1;
 }
 


