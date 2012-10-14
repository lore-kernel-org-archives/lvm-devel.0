From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 21:21:16 +0000 (UTC)
Subject: master - test: coverage
Message-ID: <20121014212116.0D5CF22FD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6f53b5c0d2a23f73af7d4a2778dfc0da4da0944
Commit:        a6f53b5c0d2a23f73af7d4a2778dfc0da4da0944
Parent:        920352da70245f9b385aa0465f9ee88091676371
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 21:57:33 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 14 23:14:48 2012 +0200

test: coverage

Improve a bit code coverage.
Use lvm shell to reduce a bit CPU time.
---
 test/shell/covercmd.sh      |   20 ++++++++++++++------
 test/shell/lvcreate-thin.sh |    1 +
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index 3fa9ea5..0514468 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -28,15 +28,23 @@ vgcreate -c n $vg $(cat DEVICES)
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 
 # test *scan and *display tools
+cat <<EOF | lvm
 pvscan
 vgscan
 lvscan
 lvmdiskscan
-vgdisplay --units k
-lvdisplay --units g
+vgdisplay --units k $vg
+lvdisplay --units g $vg
+pvdisplay -c "$dev1"
+pvdisplay -s "$dev1"
+vgdisplay -c $vg
+vgdisplay -s $vg
+lvdisplay -c $vg
+EOF
+
 for i in h b s k m g t p e H B S K M G T P E; do
-	pvdisplay --units $i "$dev1"
-done
+	echo pvdisplay --units $i "$dev1"
+done | lvm
 
 # test vgexport vgimport tools
 vgchange -an $vg
@@ -53,8 +61,8 @@ done
 
 for i in pr "p rw" an ay "-monitor y" "-monitor n" \
         -resync -refresh "-addtag MYTAG" "-deltag MYETAG"; do
-	lvchange -$i $vg/$lv
-done
+	echo lvchange -$i $vg/$lv
+done | lvm
 
 pvck "$dev1"
 vgck $vg
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 8ac5468..e651a81 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -162,6 +162,7 @@ check vg_field $vg lv_count 6
 lvremove -ff $vg
 check vg_field $vg lv_count 0
 
+lvdisplay $vg
 
 # Fail cases
 # Too small pool size (1 extent 64KB) for given chunk size


