From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 15:39:14 +0000 (GMT)
Subject: master - tests: ensure mnt is defined before trap install
Message-ID: <20200919153914.E4ACF3870879@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e3e2c74edb4d7644a20cd832590d4a90f72f0c4
Commit:        8e3e2c74edb4d7644a20cd832590d4a90f72f0c4
Parent:        530fc17b38b5363d5258d7ff5bc38f7863a585d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 18 21:59:24 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 17:30:51 2020 +0200

tests: ensure mnt is defined before trap install

---
 test/shell/integrity-blocksize.sh | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 60513e516..03410c204 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -32,6 +32,8 @@ cleanup_mounted_and_teardown()
 	aux teardown
 }
 
+mnt="mnt"
+mkdir -p $mnt
 
 # Tests with fs block sizes require a libblkid version that shows BLOCK_SIZE
 aux prepare_devs 1
@@ -65,9 +67,6 @@ aux extend_filter "a|$LOOP4|"
 
 aux lvmconf 'devices/scan = "/dev"'
 
-mnt="mnt"
-mkdir -p $mnt
-
 vgcreate $vg1 $LOOP1 $LOOP2
 vgcreate $vg2 $LOOP3 $LOOP4
 


