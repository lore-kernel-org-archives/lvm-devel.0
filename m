From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Oct 2012 14:13:50 +0000 (UTC)
Subject: master - scripts: blk-availability - use full name for clarity
Message-ID: <20121015141350.701CC22C8@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5afa2ffcaaa69925673b1c0c82ebb3c1f66b1906
Commit:        5afa2ffcaaa69925673b1c0c82ebb3c1f66b1906
Parent:        3ff080c59190caa6f5002d73f4da63b7e4e39620
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 15 16:10:58 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 15 16:10:58 2012 +0200

scripts: blk-availability - use full name for clarity

"Stopping blk-availability" -> "Stopping block device availability:"
---
 scripts/blk_availability_init_red_hat.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index 60dd240..5638def 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -46,7 +46,7 @@ case "$1" in
 	;;
 
   stop)
-	action "Stopping blk-availability" $sbindir/$script $options
+	action "Stopping block device availability:" $sbindir/$script $options
 	rm -f $LOCK_FILE
 	;;
 


