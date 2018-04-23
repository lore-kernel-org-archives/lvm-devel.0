From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:51:21 -0400
Subject: master - scan: put dev back on caller's list
Message-ID: <201804231351.w3NDpLd9032420@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2b10daf694bea490044b752209a416f886373ea
Commit:        c2b10daf694bea490044b752209a416f886373ea
Parent:        e7670d333855ecccb21b30bc6b4525d6bafaa940
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 15 14:17:51 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:47 2018 -0500

scan: put dev back on caller's list

Commit 6e442875613915e506440e59a290b56756df2521 missed
adding devs back to caller's list.
---
 lib/label/label.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 38db733..c35818a 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -513,6 +513,7 @@ static int _scan_list(struct dm_list *devs, int *failed)
 			if (!_scan_dev_open(devl->dev)) {
 				log_debug_devs("%s: Failed to open device.", dev_name(devl->dev));
 				dm_list_del(&devl->list);
+				dm_list_add(&done_devs, &devl->list);
 				scan_failed_count++;
 				continue;
 			}
@@ -561,8 +562,8 @@ static int _scan_list(struct dm_list *devs, int *failed)
 	if (!dm_list_empty(devs))
 		goto scan_more;
 
-	log_debug_devs("Scanned %d devices: %d for lvm, %d failed.",
-			dm_list_size(&done_devs), scan_lvm_count, scan_failed_count);
+	log_debug_devs("Scanned devices: %d lvm, %d failed.",
+			scan_lvm_count, scan_failed_count);
 
 	if (failed)
 		*failed = scan_failed_count;


