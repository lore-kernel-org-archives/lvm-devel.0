From: Gabriel de Perthuis <g2p.code@gmail.com>
Date: Thu, 26 Sep 2013 09:33:44 +0200
Subject: [PATCH] pvcreate: Create a bootloader embedding area by default
Message-ID: <1380180824-17931-1-git-send-email-g2p.code@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Default to 1M, to match the amount available to the bootloader on a
partition table with modern alignment constraints.
---
 lib/config/defaults.h   | 1 +
 lib/metadata/metadata.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index d200331..2f5d17d 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -103,10 +103,11 @@
 #define DEFAULT_MAX_LV 0
 #define DEFAULT_ALLOC_POLICY ALLOC_NORMAL
 #define DEFAULT_MIRROR_LOGS_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_MAXIMISE_CLING 1
 #define DEFAULT_CLUSTERED 0
+#define DEFAULT_BOOTLOADERAREASIZE 2048 /* sectors */
 
 #define DEFAULT_MSG_PREFIX "  "
 #define DEFAULT_CMD_NAME 0
 #define DEFAULT_OVERWRITE 0
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1e34f83..c351741 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1435,11 +1435,11 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 	pp->yes = 0;
 	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
 	pp->rp.restorefile = 0;
 	pp->rp.idp = 0;
 	pp->rp.ba_start = 0;
-	pp->rp.ba_size = 0;
+	pp->rp.ba_size = DEFAULT_BOOTLOADERAREASIZE;
 	pp->rp.pe_start = PV_PE_START_CALC;
 	pp->rp.extent_count = 0;
 	pp->rp.extent_size = 0;
 }
 
-- 
1.8.4.25.g05e4ae6


