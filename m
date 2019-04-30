From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:31:17 -0400
Subject: stable-2.02 - tests: extend
Message-ID: <201904301131.x3UBVHsa020522@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71b9cb8e0f688289a817a8ec6b88548023e5c3d0
Commit:        71b9cb8e0f688289a817a8ec6b88548023e5c3d0
Parent:        057d8668890367525fc830d7a08413eefe0243af
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 16:01:39 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 13:16:19 2019 +0200

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
 


