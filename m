From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:22 -0500
Subject: master - lvmlockd: fix error return code for _init_vg_sanlock
Message-ID: <201812212046.wBLKkMoA021149@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7832d3566868408ebf6d4c5d708e3efab3d48a67
Commit:        7832d3566868408ebf6d4c5d708e3efab3d48a67
Parent:        98924e4703bd798f4e872fbc7e6c6e32a199e102
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 12:08:10 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:30 2018 +0100

lvmlockd: fix error return code for _init_vg_sanlock

In few cases error paths from initialization were returned as
'success == 1'.

Also assing num_mb with single compare checking valid sector_size.

For dumb compiler make num_mb always defined.
---
 lib/locking/lvmlockd.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 530378c..9fb7b36 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -632,7 +632,7 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 	struct device *sector_dev;
 	uint32_t sector_size = 0;
 	unsigned int phys_block_size, block_size;
-	int num_mb;
+	int num_mb = 0;
 	int result;
 	int ret;
 
@@ -655,25 +655,20 @@ static int _init_vg_sanlock(struct cmd_context *cmd, struct volume_group *vg, in
 			sector_size = phys_block_size;
 			sector_dev = pvl->pv->dev;
 		} else if (sector_size != phys_block_size) {
-			log_warn("Inconsistent sector sizes for %s and %s.",
-				 dev_name(pvl->pv->dev), dev_name(sector_dev));
-			return 1;
+			log_error("Inconsistent sector sizes for %s and %s.",
+				  dev_name(pvl->pv->dev), dev_name(sector_dev));
+			return 0;
 		}
 	}
 
-	if ((sector_size != 512) && (sector_size != 4096)) {
-		log_error("Unknown sector size.");
-		return 1;
-	}
-
 	log_debug("Using sector size %u for sanlock LV", sector_size);
 
 	/* Base starting size of sanlock LV is 256MB/1GB for 512/4K sectors */
-	if (sector_size == 512)
-		num_mb = 256;
-	else if (sector_size == 4096)
-		num_mb = 1024;
-
+	switch (sector_size) {
+	case 512: num_mb = 256; break;
+	case 4096: num_mb = 1024; break;
+	default: log_error("Unknown sector size %u.", sector_size); return 0;
+	}
 
 	/*
 	 * Creating the sanlock LV writes the VG containing the new lvmlock


