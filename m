From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 11 Oct 2018 05:07:46 -0400
Subject: master - config: Fix version for VDO
Message-ID: <201810110907.w9B97k4g028435@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48768cc5be64504863c80d61f3d8f6ec4fbfe589
Commit:        48768cc5be64504863c80d61f3d8f6ec4fbfe589
Parent:        6462e8dffc7ed53973ce796cec18fecc0fb89d77
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 11 10:53:28 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Oct 11 11:06:23 2018 +0200

config: Fix version for VDO

---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b47b225..636446f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -609,7 +609,7 @@ cfg_runtime(allocation_thin_pool_chunk_size_CFG, "thin_pool_chunk_size", allocat
 cfg(allocation_physical_extent_size_CFG, "physical_extent_size", allocation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_EXTENT_SIZE, vsn(2, 2, 112), NULL, 0, NULL,
 	"Default physical extent size in KiB to use for new VGs.\n")
 
-#define VDO_1ST_VSN vsn(3, 0, 0)
+#define VDO_1ST_VSN vsn(2, 3, 0)
 cfg(allocation_vdo_use_compression_CFG, "vdo_use_compression", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_USE_COMPRESSION, VDO_1ST_VSN, NULL, 0, NULL,
 	"Enables or disables compression when creating a VDO volume.\n"
 	"Compression may be disabled if necessary to maximize performance\n"


