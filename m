From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 1 Dec 2017 12:33:34 -0500
Subject: master - test: disable new reshape test until target version 1.13.1
Message-ID: <201712011733.vB1HXYuS026741@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3688eeeea0a81e8dbc02d1c9d46cb983a4d8d79b
Commit:        3688eeeea0a81e8dbc02d1c9d46cb983a4d8d79b
Parent:        9681d98cc401681ab60033b6595caf8355f8748d
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Dec 1 18:33:11 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Dec 1 18:33:11 2017 +0100

test: disable new reshape test until target version 1.13.1

---
 test/shell/lvconvert-raid-reshape-load.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-load.sh b/test/shell/lvconvert-raid-reshape-load.sh
index c01127b..4ccf01f 100644
--- a/test/shell/lvconvert-raid-reshape-load.sh
+++ b/test/shell/lvconvert-raid-reshape-load.sh
@@ -20,7 +20,7 @@ LVM_SKIP_LARGE_TESTS=1
 # Test reshaping under io load
 
 which mkfs.ext4 || skip
-aux have_raid 1 12 0 || skip
+aux have_raid 1 13 1 || skip
 
 mpoint=/tmp/mpoint.$$
 


