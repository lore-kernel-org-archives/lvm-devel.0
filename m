From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 1 Nov 2019 11:26:20 -0400
Subject: stable-2.02 - tests: skip test if scsi_debug is not available
Message-ID: <201911011526.xA1FQKU4016371@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ae481bb301d8c8b3a8ea3725a0ae57f3d7bca5c
Commit:        4ae481bb301d8c8b3a8ea3725a0ae57f3d7bca5c
Parent:        2cd30c0d44996cfafcf450201948139f76570ab7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 1 16:07:20 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 1 16:12:39 2019 +0100

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
 


