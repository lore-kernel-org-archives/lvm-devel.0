From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 19:22:56 -0400
Subject: master - tests: drop type
Message-ID: <201707112322.v6BNMuUE010856@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ec9b845aaa6f155fc30951e7f479327402e287f0
Commit:        ec9b845aaa6f155fc30951e7f479327402e287f0
Parent:        a1ed9bc1452129ca0553d76d890049d5873dd91f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 01:20:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 01:21:44 2017 +0200

tests: drop type

Assuming test wanted to check $lv3 does not exists.
---
 test/shell/process-each-lv.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/process-each-lv.sh b/test/shell/process-each-lv.sh
index 14cb110..e9cea81 100644
--- a/test/shell/process-each-lv.sh
+++ b/test/shell/process-each-lv.sh
@@ -295,7 +295,7 @@ vgchange --addtag V5  $vg5
 lvremove $vg1/$lv1 @V35
 check lv_not_exists $vg1 $lv1
 check lv_not_exists $vg3 $lv1 $lv2 $lv3
-check lv_not_exists $vg5 $lv1 $lv2 $lv3not $lv4 $lv5
+check lv_not_exists $vg5 $lv1 $lv2 $lv3 $lv4 $lv5
 # verify unremoved exist
 check lv_exists $vg2 $lv1 $lv2
 


