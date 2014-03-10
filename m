From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:21 +0000 (UTC)
Subject: master - tests: reuse existing check dev_md5sum
Message-ID: <20140310112721.7FF8B603FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa23234e71ce8c5270e5b45bb55556d563383dfc
Commit:        fa23234e71ce8c5270e5b45bb55556d563383dfc
Parent:        d080abf7d60fc23343670e444d4cd26745e3e5d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 7 10:51:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

tests: reuse existing check dev_md5sum

Create md5sum in reusable way and use exiting check function.
---
 test/shell/snapshot-reactivate.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/shell/snapshot-reactivate.sh b/test/shell/snapshot-reactivate.sh
index a4478b7..28e1d62 100644
--- a/test/shell/snapshot-reactivate.sh
+++ b/test/shell/snapshot-reactivate.sh
@@ -19,8 +19,7 @@
 
 # Snapshot should remain unmodified
 check_s_() {
-	rm -f debug.log
-	md5sum -c md5
+	check dev_md5sum $vg s
 	#diff data "$DM_DEV_DIR/$vg/s"
 }
 
@@ -31,7 +30,7 @@ aux prepare_vg
 # 8M file with some random data
 dd if=/dev/urandom of=data bs=1M count=1
 dd if=data of=data bs=1M count=7 seek=1
-echo "$(md5sum data | cut -d' ' -f1)  $DM_DEV_DIR/$vg/s" >md5
+echo "$(md5sum data | cut -d' ' -f1)  $DM_DEV_DIR/$vg/s" >md5.${vg}-s
 
 lvcreate -aey -L 8M -n o $vg
 dd if=data of="$DM_DEV_DIR/$vg/o" bs=1M


