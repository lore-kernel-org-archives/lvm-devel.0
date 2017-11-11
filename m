From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Nov 2017 19:03:29 -0500
Subject: master - tests: use nonflusing status
Message-ID: <201711110003.vAB03TIS009614@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe69a8d21573f37cb3fd503ee40ceb00b555a7e2
Commit:        fe69a8d21573f37cb3fd503ee40ceb00b555a7e2
Parent:        dd06a0a4a68d5619050da76acdd508a89390d5f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 10 16:18:41 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 11 01:00:35 2017 +0100

tests: use nonflusing status

Avoid being blocked when reporting status with flushing on some stacked
device tree.
---
 test/lib/utils.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 65bb1e6..bf472a4 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -180,7 +180,7 @@ STACKTRACE() {
 			echo "<======== Inactive table ========>"
 			dmsetup table --inactive  | grep "$PREFIX" | sed -e "s,^,## DMITABLE: ,"
 			echo "<======== Status ========>"
-			dmsetup status | grep "$PREFIX" | sed -e "s,^,## DMSTATUS: ,"
+			dmsetup status --noflush | grep "$PREFIX" | sed -e "s,^,## DMSTATUS: ,"
 			echo "<======== Tree ========>"
 			dmsetup ls --tree | sed -e "s,^,## DMTREE:   ,"
 			echo "<======== Recursive list of $DM_DEV_DIR ========>"


