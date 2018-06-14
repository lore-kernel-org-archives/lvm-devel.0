From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 16:03:24 -0400
Subject: master - tests: bigger lv
Message-ID: <201806142003.w5EK3ONp004089@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b1729dbcddb7243f556b286f958cd4a97f821d65
Commit:        b1729dbcddb7243f556b286f958cd4a97f821d65
Parent:        f4abbafde7ac1918ecb54c23ec90d2d9dcdc9c02
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 14 21:52:22 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 14 22:02:01 2018 +0200

tests: bigger lv

Although throttling slows down things considerable, it still could
reach the end before next test so use bigger LV.
---
 test/shell/pvmove-abort.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 49847c0..1445799 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -34,8 +34,8 @@ for backgroundarg in "-b" "" ;
 do
 
 # Create multisegment LV
-lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
-lvcreate -an -Zn -l40 -n $lv2 $vg "$dev2"
+lvcreate -an -Zn -l40 -n $lv1 $vg "$dev1"
+lvcreate -an -Zn -l50 -n $lv2 $vg "$dev2"
 
 cmd1=(pvmove -i1 $backgroundarg $mode "$dev1" "$dev3")
 cmd2=(pvmove -i1 $backgroundarg $mode "$dev2" "$dev3")


