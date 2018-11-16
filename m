From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:33:09 -0500
Subject: master - tests: extend
Message-ID: <201811162333.wAGNX9fA016053@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fd8001a9fc7ea3a49c2b9fc3c3e20367e5dcf401
Commit:        fd8001a9fc7ea3a49c2b9fc3c3e20367e5dcf401
Parent:        83d9ea73486c92a48725648d2ee2b5fac2fb6b5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 16:01:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

tests: extend

---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 3731bf6..437a04e 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -171,7 +171,9 @@ wait_for_change_ $pre
 lvchange -an $vg
 
 #
-fake_metadata_ 350 2 >data
+DATA=300  # Newer version of thin-pool have hidden reserve, so use lower value
+aux target_at_least dm-thin-pool 1 20 0 || DATA=350
+fake_metadata_ $DATA 2 >data
 lvchange -ay $vg/$lv1
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 


