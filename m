From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 15:39:16 +0000 (GMT)
Subject: master - tests: use faster awk generator
Message-ID: <20200919153916.1188838708AA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7c58c636debe351ddd97371c8d32c3f79cdbf79
Commit:        f7c58c636debe351ddd97371c8d32c3f79cdbf79
Parent:        8e3e2c74edb4d7644a20cd832590d4a90f72f0c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 15:57:29 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 17:30:51 2020 +0200

tests: use faster awk generator

Shortens log length.
---
 test/shell/writecache-blocksize.sh | 8 +++-----
 test/shell/writecache-large.sh     | 6 +++---
 test/shell/writecache.sh           | 6 +++---
 3 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/test/shell/writecache-blocksize.sh b/test/shell/writecache-blocksize.sh
index 13001760a..523d4ab80 100644
--- a/test/shell/writecache-blocksize.sh
+++ b/test/shell/writecache-blocksize.sh
@@ -32,9 +32,9 @@ aux cleanup_scsi_debug_dev
 mnt="mnt"
 mkdir -p $mnt
 
-for i in `seq 1 16384`; do echo -n "A" >> fileA; done
-for i in `seq 1 16384`; do echo -n "B" >> fileB; done
-for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
@@ -338,5 +338,3 @@ lvremove $vg/$lv2
 vgremove $vg
 
 aux cleanup_scsi_debug_dev
-
-
diff --git a/test/shell/writecache-large.sh b/test/shell/writecache-large.sh
index b52eaf6ab..fc8f379cf 100644
--- a/test/shell/writecache-large.sh
+++ b/test/shell/writecache-large.sh
@@ -33,9 +33,9 @@ blockdev --getpbsz "$dev2"
 mnt="mnt"
 mkdir -p $mnt
 
-for i in `seq 1 16384`; do echo -n "A" >> fileA; done
-for i in `seq 1 16384`; do echo -n "B" >> fileB; done
-for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 39ef31930..99be31e6b 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -65,9 +65,9 @@ blockdev --getpbsz "$dev2"
 mnt="mnt"
 mkdir -p $mnt
 
-for i in `seq 1 16384`; do echo -n "A" >> fileA; done
-for i in `seq 1 16384`; do echo -n "B" >> fileB; done
-for i in `seq 1 16384`; do echo -n "C" >> fileC; done
+awk 'BEGIN { while (z++ < 16384) printf "A" }' > fileA
+awk 'BEGIN { while (z++ < 16384) printf "B" }' > fileB
+awk 'BEGIN { while (z++ < 16384) printf "C" }' > fileC
 
 # generate random data
 dd if=/dev/urandom of=randA bs=512K count=2


