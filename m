From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:31:18 -0400
Subject: stable-2.02 - tests: update parm for new kernel
Message-ID: <201904301131.x3UBVIES020527@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9d7afaaab85404a562942f4662de8a2e7739d8fb
Commit:        9d7afaaab85404a562942f4662de8a2e7739d8fb
Parent:        71b9cb8e0f688289a817a8ec6b88548023e5c3d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 18 22:04:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 13:16:31 2019 +0200

tests: update parm for new kernel

---
 test/shell/lvextend-thin-metadata-dmeventd.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 437a04e..20b70d3 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -90,7 +90,9 @@ lvchange -an $vg/pool
 
 # Consume more then (100% - 4MiB) out of 32MiB metadata volume  (>87.5%)
 # (Test for less than 4MiB free space in metadata, which is less than 25%)
-fake_metadata_ 7400 2 >data
+DATA=7200  # Newer version of thin-pool have hidden reserve, so use lower value
+aux target_at_least dm-thin-pool 1 20 0 || DATA=7400
+fake_metadata_ "$DATA" 2 >data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv2"
 # Swap volume with restored fake metadata
 lvconvert -y --chunksize 64k --thinpool $vg/pool --poolmetadata $vg/$lv2


