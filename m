From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 07:21:41 -0500
Subject: master - test: raid1 down convert to linear
Message-ID: <201703091221.v29CLep3017803@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b1b66c2669d0da8aade44fa063a930ca402c363
Commit:        6b1b66c2669d0da8aade44fa063a930ca402c363
Parent:        4b0ae266c2d20a682329c37bb0e8cd28b76b9c95
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 13:21:21 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 13:21:21 2017 +0100

test: raid1 down convert to linear

Missed one test in last commit.
---
 test/shell/lvconvert-cache-raid.sh |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 3807493..5b693a1 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -93,9 +93,10 @@ lvconvert -m+1 --type raid1 $vg/cpool_cdata
 check lv_field $vg/cpool_cdata layout "raid,raid1"
 check lv_field $vg/cpool_cdata role "private,cache,pool,data"
 
-lvconvert -m-1  $vg/cpool_cmeta
+not lvconvert -m-1  $vg/cpool_cmeta
+lvconvert -y -m-1  $vg/cpool_cmeta
 check lv_field $vg/cpool_cmeta layout "linear"
-lvconvert -m-1  $vg/cpool_cdata
+lvconvert -y -m-1  $vg/cpool_cdata
 check lv_field $vg/cpool_cdata layout "linear"
 
 lvremove -f $vg


