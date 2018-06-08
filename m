From: David Teigland <teigland@sourceware.org>
Date: Fri, 8 Jun 2018 15:02:31 -0400
Subject: master - tests: remove vgsplit-usage cluster test
Message-ID: <201806081902.w58J2VCO003646@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ce9579099a08e4d3cb0c0805517d3352b487b86
Commit:        4ce9579099a08e4d3cb0c0805517d3352b487b86
Parent:        1c59140f5fbd48139ac008c8c1ab1aefc4288698
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 8 13:08:32 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 8 14:01:05 2018 -0500

tests: remove vgsplit-usage cluster test

---
 test/shell/vgsplit-usage.sh |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/test/shell/vgsplit-usage.sh b/test/shell/vgsplit-usage.sh
index 38f3964..33a606e 100644
--- a/test/shell/vgsplit-usage.sh
+++ b/test/shell/vgsplit-usage.sh
@@ -95,13 +95,6 @@ not vgsplit --alloc cling $vg1 $vg2 "$dev1" 2>err;
 grep "Volume group \"$vg2\" exists, but new VG option specified" err
 vgremove $vg1 $vg2
 
-# vgsplit rejects split because clustered given with existing vg
-vgcreate -M$mdatype $vg1 "$dev1" "$dev2"
-vgcreate -M$mdatype $vg2 "$dev3" "$dev4"
-not vgsplit $vg1 $vg2 "$dev1" 2>err
-grep "Volume group \"$vg2\" exists, but new VG option specified" err
-vgremove $vg1 $vg2
-
 # vgsplit rejects vg with active lv
 pvcreate -M$mdatype -ff "$dev3" "$dev4"
 vgcreate -M$mdatype $vg1 "$dev1" "$dev2"


