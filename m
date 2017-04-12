From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 17:06:41 -0400
Subject: master - tests: aux defines fsadm path
Message-ID: <201704122106.v3CL6fD6024334@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59d54d70e73f2ba60a0714a04af3699c23503761
Commit:        59d54d70e73f2ba60a0714a04af3699c23503761
Parent:        1e64386dc69a0e13404eefc2deb0c3908632457c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 12 23:03:08 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 23:05:50 2017 +0200

tests: aux defines fsadm path

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bc10b44..214db4e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1156,6 +1156,7 @@ global/thin_repair_executable = "$LVM_TEST_THIN_REPAIR_CMD"
 global/use_lvmetad = $LVM_TEST_LVMETAD
 global/use_lvmpolld = $LVM_TEST_LVMPOLLD
 global/use_lvmlockd = $LVM_TEST_LVMLOCKD
+global/fsadm_executable = "$TESTDIR/lib/fsadm"
 log/activation = 1
 log/file = "$TESTDIR/debug.log"
 log/indent = 1


