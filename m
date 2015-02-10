From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 10 Feb 2015 11:43:13 +0000 (UTC)
Subject: master - test: Fix a typo in shell/pvmove-restart.sh.
Message-ID: <20150210114313.E54706114E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ee3bcb877b081dd6281644d4c9c366dd08ad1c1
Commit:        2ee3bcb877b081dd6281644d4c9c366dd08ad1c1
Parent:        b6f558adcc3b08cb627aca0a0cddbe65bdd19052
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Tue Feb 10 12:42:05 2015 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Tue Feb 10 12:42:05 2015 +0100

test: Fix a typo in shell/pvmove-restart.sh.

---
 test/shell/pvmove-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index b4a2893..3c4947d 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -40,7 +40,7 @@ wait
 
 # Simulate reboot - forcibly remove related devices
 dmsetup table
-dmsetup ls --exec echo | egrep '$vg-$lv1|$vg-pvmove0' | xargs -r -n 1 dmsetup remove
+dmsetup ls --exec echo | egrep "$vg-$lv1|$vg-pvmove0" | xargs -r -n 1 dmsetup remove
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


