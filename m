From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:57:38 +0000 (UTC)
Subject: master - tests: drop * from dmsetup
Message-ID: <20140924085738.0B11A610D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9acbb0695f96a400f2be6c1c5bf76b914653c200
Commit:        9acbb0695f96a400f2be6c1c5bf76b914653c200
Parent:        bc5031c28383d492aa0c349fe2e058c2c26b2934
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 01:11:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:54:48 2014 +0200

tests: drop * from dmsetup

We cannot use shell expansion for dmsetup here.
---
 test/shell/pvmove-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index dde7308..effa43d 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -41,7 +41,7 @@ wait
 # Simulate reboot - forcibly remove related devices
 dmsetup table
 dmsetup remove $vg-$lv1
-dmsetup remove "$DM_DEV_DIR/mapper/$vg-pvmove0*"
+dmsetup remove "$DM_DEV_DIR/mapper/$vg-pvmove0"
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


