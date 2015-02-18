From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 18 Feb 2015 11:29:49 +0000 (UTC)
Subject: master - test: Avoid a race in pvmove-restart.sh.
Message-ID: <20150218112949.3F36060516@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88411fb6f97937c6cac573e2720ae30fafe96761
Commit:        88411fb6f97937c6cac573e2720ae30fafe96761
Parent:        733e3f6f983d26c346c5426915abfd9594e85a49
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Feb 18 12:27:47 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Feb 18 12:27:47 2015 +0100

test: Avoid a race in pvmove-restart.sh.

---
 test/shell/pvmove-restart.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 5e4fd8b..398095b 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -15,7 +15,9 @@
 
 aux prepare_pvs 3 60
 
-vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
+vgcreate -s 128k $vg "$dev1" "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
+vgextend $vg "$dev3"
 
 for mode in "--atomic" ""
 do
@@ -32,7 +34,7 @@ aux delay_dev "$dev3" 0 100
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
-sleep 1
+while not dmsetup status "$vg-pvmove0"; do sleep .1; done
 kill -9 $PVMOVE
 wait
 


