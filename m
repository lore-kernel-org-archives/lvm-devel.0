From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:47 +0000 (UTC)
Subject: master - test: Do not rely on dev/mapper/* nodes in pvmove-restart.sh.
Message-ID: <20150205134247.A76CD601D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b80e949ea320d202f5ccade2e79a5a3c5937368
Commit:        8b80e949ea320d202f5ccade2e79a5a3c5937368
Parent:        d04c7ca0b61e42f831b90e54ecbb7fa6e943edd4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 14 11:11:50 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:20 2015 +0100

test: Do not rely on dev/mapper/* nodes in pvmove-restart.sh.

---
 test/shell/pvmove-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index effa43d..da6f3e5 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -41,7 +41,7 @@ wait
 # Simulate reboot - forcibly remove related devices
 dmsetup table
 dmsetup remove $vg-$lv1
-dmsetup remove "$DM_DEV_DIR/mapper/$vg-pvmove0"
+dmsetup ls --exec echo | grep $vg-pvmove0 | xargs dmsetup remove
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


