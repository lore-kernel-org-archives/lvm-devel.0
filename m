From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:57 -0400
Subject: master - tests: for cluster testing we always need exclusive mirrors
Message-ID: <201908091058.x79AwvSG031650@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05c7e09e7100292cbdf713256ceec76b53ddd57d
Commit:        05c7e09e7100292cbdf713256ceec76b53ddd57d
Parent:        505c1d56e8d48a479ef95c7890d3c9e066b66f33
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 20 11:07:43 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:21 2019 +0200

tests: for cluster testing we always need exclusive mirrors

Cluster test would fail without exlusively activated mirror.
FIXME: test is still broken, since LV2 is not active after split.
---
 test/shell/lvconvert-mirror-split.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror-split.sh b/test/shell/lvconvert-mirror-split.sh
index 40720a4..00291ec 100644
--- a/test/shell/lvconvert-mirror-split.sh
+++ b/test/shell/lvconvert-mirror-split.sh
@@ -20,7 +20,7 @@ aux prepare_vg 3
 # Mirror split tests
 ###########################################
 # 3-way to 2-way/linear
-lvcreate --type mirror -m 2 -l 2 -n $lv1 $vg
+lvcreate -aey --type mirror -m 2 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
 lvconvert --splitmirrors 1 -n $lv2 -vvvv $vg/$lv1
 


