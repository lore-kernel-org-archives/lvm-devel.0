From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jun 2020 18:16:22 +0000 (GMT)
Subject: master - tests: fix typo in writecache-blocksize
Message-ID: <20200611181622.E1895383F859@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9f38e95a2f84f148dae1a8ec440adc29eb12d513
Commit:        9f38e95a2f84f148dae1a8ec440adc29eb12d513
Parent:        f32e85ae519d9c278d7e76329438f976e91ac317
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 11 13:15:38 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 11 13:15:38 2020 -0500

tests: fix typo in writecache-blocksize

---
 test/shell/writecache-blocksize.sh | 1 -
 1 file changed, 1 deletion(-)

diff --git a/test/shell/writecache-blocksize.sh b/test/shell/writecache-blocksize.sh
index 42c963c29..13001760a 100644
--- a/test/shell/writecache-blocksize.sh
+++ b/test/shell/writecache-blocksize.sh
@@ -264,7 +264,6 @@ blockdev --getpbsz "$dev2"
 
 # lbs 512, pbs 4k, xfs 4k, wc 4k
 vgcreate $SHARED $vg "$dev1"
-vgcreate $SHARED $vg "$dev1"
 vgextend $vg "$dev2"
 lvcreate -n $lv1 -l 8 -an $vg "$dev1"
 lvcreate -n $lv2 -l 4 -an $vg "$dev2"


