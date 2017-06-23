From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 17:33:51 -0400
Subject: master - tests: use allocate policy in raid test
Message-ID: <201706232133.v5NLXpd4022724@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a50a28f3e8e5a1a7ecbf247f27cc8178ee286bf
Commit:        2a50a28f3e8e5a1a7ecbf247f27cc8178ee286bf
Parent:        1598bf154e80f43a7b215a69dc44bd9a87b166df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 23:22:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 23:32:44 2017 +0200

tests: use allocate policy in raid test

---
 test/shell/lvconvert-repair-raid-dmeventd.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid-dmeventd.sh b/test/shell/lvconvert-repair-raid-dmeventd.sh
index 1a9e993..84b0591 100644
--- a/test/shell/lvconvert-repair-raid-dmeventd.sh
+++ b/test/shell/lvconvert-repair-raid-dmeventd.sh
@@ -17,6 +17,9 @@ SKIP_WITH_LVMPOLLD=1
 which mkfs.ext3 || skip
 aux have_raid 1 3 0 || skip
 
+aux lvmconf \
+	'activation/raid_fault_policy = "allocate"'
+
 aux prepare_dmeventd
 aux prepare_vg 5
 
@@ -27,7 +30,7 @@ lvdisplay --maps $vg
 aux wait_for_sync $vg 4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 "$DM_DEV_DIR/$vg/4way"
-sleep 10 # FIXME: need a "poll" utility, akin to "check"
+sleep 5 # FIXME: need a "poll" utility, akin to "check"
 aux enable_dev "$dev2" "$dev4"
 
 vgremove -ff $vg


