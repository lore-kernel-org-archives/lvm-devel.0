From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Feb 2018 07:58:02 -0500
Subject: master - tests: update
Message-ID: <201802151258.w1FCw2bp005126@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5401fbd34371dfed74f981eb1d4c5b4b3220cc2
Commit:        f5401fbd34371dfed74f981eb1d4c5b4b3220cc2
Parent:        552e60b3a1e35329a47d6112c548ada124b5a4e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 14 23:08:26 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 15 13:56:35 2018 +0100

tests: update

---
 test/shell/pvmove-basic.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 42f165b..2fc71e2 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -41,7 +41,7 @@ prepare_lvs_() {
 	lvextend -l+2 $vg/$lv1 "$dev3"
 	lvextend -l+2 $vg/$lv1 "$dev1"
 	check lv_on $vg $lv1 "$dev1" "$dev2" "$dev3"
-	lvcreate -l1 -n $lv3 $vg "$dev2"
+	lvcreate -aey -l1 -n $lv3 $vg "$dev2"
 	check lv_on $vg $lv3 "$dev2"
 	aux mkdev_md5sum $vg $lv1
 	aux mkdev_md5sum $vg $lv2


