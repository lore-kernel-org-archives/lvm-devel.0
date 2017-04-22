From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Sat, 22 Apr 2017 01:49:50 -0400
Subject: master - test: consider changed default
Message-ID: <201704220549.v3M5nonf014959@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=149e4fa04b68da8979936ea3eb5bc68fb27127b2
Commit:        149e4fa04b68da8979936ea3eb5bc68fb27127b2
Parent:        7c7122a3b1482900f71168f7ce0fec176eb36f8a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Apr 22 00:42:09 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Apr 22 00:42:09 2017 +0200

test: consider changed default

commit b81b4aad24807d2aa4968aa9fc7d970a65623620
raised the region size so demand the sizes the
test checks for.
---
 .../lvconvert-raid-reshape-linear_to_striped.sh    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
index 042cb33..cef35cd 100644
--- a/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
+++ b/test/shell/lvconvert-raid-reshape-linear_to_striped.sh
@@ -45,7 +45,7 @@ aux wait_for_sync $vg $lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 
 # Convert raid1 -> raid5_n
-lvconvert -y --ty raid5_n $vg/$lv1
+lvconvert -y --ty raid5_n --stripesize 64K --regionsize 512K $vg/$lv1
 fsck -fn $DM_DEV_DIR/$vg/$lv1
 check lv_field $vg/$lv1 segtype "raid5_n"
 check lv_field $vg/$lv1 stripes 2


