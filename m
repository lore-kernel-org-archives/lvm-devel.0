From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 18 Feb 2015 09:22:12 +0000 (UTC)
Subject: master - test: Make pvmove0 device removal more robust, in pvmove-restart.sh.
Message-ID: <20150218092212.3EC5560D68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=733e3f6f983d26c346c5426915abfd9594e85a49
Commit:        733e3f6f983d26c346c5426915abfd9594e85a49
Parent:        10b8d2a4ea538c21cf991fd608de47a9c18f85f4
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Feb 18 10:17:43 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Feb 18 10:21:06 2015 +0100

test: Make pvmove0 device removal more robust, in pvmove-restart.sh.

---
 test/shell/pvmove-restart.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 98ff6b4..5e4fd8b 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -39,8 +39,8 @@ wait
 # Simulate reboot - forcibly remove related devices
 
 # First take down $lv1 then it's pvmove0
-dmsetup ls --exec echo | grep "${vg}-$lv1" | xargs -r dmsetup remove
-dmsetup ls --exec echo | grep "${vg}-pvmove0" | xargs -r dmsetup remove
+while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
+while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


