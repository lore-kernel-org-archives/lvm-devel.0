From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 May 2017 09:41:42 -0400
Subject: master - tests: better skip
Message-ID: <201705101341.v4ADfgTq005488@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b817cc5746ef3bd3105a73e43aaf4b2ccd134335
Commit:        b817cc5746ef3bd3105a73e43aaf4b2ccd134335
Parent:        a1a9ae0aa5fe337935091320b6f27fb053381ff5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 12:18:56 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 10 15:40:32 2017 +0200

tests: better skip

---
 test/shell/thin-resize-match.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/shell/thin-resize-match.sh b/test/shell/thin-resize-match.sh
index c78842f..46b4531 100644
--- a/test/shell/thin-resize-match.sh
+++ b/test/shell/thin-resize-match.sh
@@ -12,13 +12,12 @@
 # ensure there is no data loss during thin-pool resize
 
 SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
 
 export LVM_TEST_THIN_REPAIR_CMD=${LVM_TEST_THIN_REPAIR_CMD-/bin/false}
 
 . lib/inittest
 
-test -e LOCAL_LVMPOLLD && skip
-
 which md5sum || skip
 
 aux have_thin 1 0 0 || skip


