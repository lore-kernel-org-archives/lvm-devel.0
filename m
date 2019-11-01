From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:32:06 -0400
Subject: master - tests: skip test if scsi_debug is not available
Message-ID: <201911011532.xA1FW60W017003@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dbaa4cdcdf312239f26029cb7f206b54587c407a
Commit:        dbaa4cdcdf312239f26029cb7f206b54587c407a
Parent:        5f064e22211959149798ebbd92497c3fc953c489
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 16:07:20 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:31:12 2019 +0100

tests: skip test if scsi_debug is not available

---
 test/shell/large-physical-sector-size.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/large-physical-sector-size.sh b/test/shell/large-physical-sector-size.sh
index 891f409..d076d86 100644
--- a/test/shell/large-physical-sector-size.sh
+++ b/test/shell/large-physical-sector-size.sh
@@ -22,7 +22,7 @@ LOGICAL_BLOCK_SIZE=4096
 # 4096 << 9 = 2MB physical block size
 PHYSICAL_BLOCK_SHIFT=9
 
-aux prepare_scsi_debug_dev 256 sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=$PHYSICAL_BLOCK_SHIFT
+aux prepare_scsi_debug_dev 256 sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=$PHYSICAL_BLOCK_SHIFT || skip
 
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "$LOGICAL_BLOCK_SIZE"
 


