From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 20:50:06 +0000 (UTC)
Subject: master - tests: more advance cleanup of running pvmove
Message-ID: <20150501205006.AF1A860AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3542fce0fba91b71792d5dabcbe96637f19de3fc
Commit:        3542fce0fba91b71792d5dabcbe96637f19de3fc
Parent:        abdfb1e75ba372072919ddad0f43f8806412d531
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 1 22:42:10 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 22:49:38 2015 +0200

tests: more advance cleanup of running pvmove

More take down more targets and use time-limited code.
---
 test/shell/pvmove-restart.sh |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 1496b35..011e6ee 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -43,10 +43,17 @@ wait
 # Simulate reboot - forcibly remove related devices
 
 # First take down $lv1 then it's pvmove0
-while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
-while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
-while dmsetup status "$vg-pvmove0_mimage_1"; do dmsetup remove "$vg-pvmove0_mimage_1" || true; done
-dmsetup table
+j=0
+for i in $lv1 pvmove0 pvmove0_mimage_1 pvmove0_mimage_0 ; do
+	while dmsetup status "$vg-$i"; do
+		dmsetup remove "$vg-$i" || {
+			j=$(($j + 1))
+			test $j -le 100 || die "Cannot take down devices."
+			sleep .1;
+		}
+	done
+done
+dmsetup table | grep $PREFIX
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


