From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:43:31 +0000 (UTC)
Subject: master - test: Make dmsetup remove more robust in pvmove-restart.
Message-ID: <20150205134331.D4CFB60BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=839ea48aa97a541638cf7f2ac6ea48695116c014
Commit:        839ea48aa97a541638cf7f2ac6ea48695116c014
Parent:        210a66fbf85fcb16ad645950b18d4ef631af3d53
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 1 09:08:26 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:51:06 2015 +0100

test: Make dmsetup remove more robust in pvmove-restart.

---
 test/shell/pvmove-restart.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 86e2efa..b4a2893 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -40,8 +40,7 @@ wait
 
 # Simulate reboot - forcibly remove related devices
 dmsetup table
-dmsetup remove $vg-$lv1
-dmsetup ls --exec echo | grep $vg-pvmove0 | xargs -r dmsetup remove
+dmsetup ls --exec echo | egrep '$vg-$lv1|$vg-pvmove0' | xargs -r -n 1 dmsetup remove
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


