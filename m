From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jun 2019 05:22:54 -0400
Subject: stable-2.02 - tests: for cluster testing we always need exclusive mirrors
Message-ID: <201906200922.x5K9MsZ4009471@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2806e6265f58308697d183a4d99967604663b734
Commit:        2806e6265f58308697d183a4d99967604663b734
Parent:        02a5921cdb90c15c93486ef8b8bd42486f6829b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 20 11:07:43 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 11:21:59 2019 +0200

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
 


