From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:01:38 -0400
Subject: master - mirror: fix calcs for maximal region_size
Message-ID: <201804201101.w3KB1c8T031179@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a19456b868849816f21cfd7517777c5999c43a89
Commit:        a19456b868849816f21cfd7517777c5999c43a89
Parent:        91965af9b1d53e6bf89ef7a849c0347277e72276
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 20 10:03:26 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:13:08 2018 +0200

mirror: fix calcs for maximal region_size

Since extent_size is no longer power_of_2 this max region size
evalution was rather producing random bitsize as a combination
of lowest bit from number of extents and extent size itself.

Correct calculation to use whole LV size and pick biggest
possible power of 2 value smaller then UINT32_MAX.
---
 WHATS_NEW             |    1 +
 lib/metadata/mirror.c |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ca9e6fa..9682d22 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Fix evaluation of maximal region size for mirror log.
   Enhance mirror log size estimation and use smaller size when possible.
   Fix incorrect mirror log size calculation on 32bit arch.
   Enhnace preloading tree creating.
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 6107619..db2883b 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -161,17 +161,17 @@ uint32_t adjusted_mirror_region_size(struct cmd_context *cmd,
 				     uint32_t extent_size, uint32_t extents,
 				     uint32_t region_size, int internal, int clustered)
 {
-	uint64_t region_max;
-	uint64_t region_min, region_min_pow2;
+	uint64_t region_max, region_min;
+	uint32_t region_min_pow2;
 
-	region_max = (UINT64_C(1) << (ffs((int)extents) - 1)) * (UINT64_C(1) << (ffs((int)extent_size) - 1));
+	region_max = (uint64_t) extents * extent_size;
 
 	if (region_max < UINT32_MAX && region_size > region_max) {
-		region_size = (uint32_t) region_max;
+		region_size =  UINT64_C(1) << (31 - clz(region_max));
 		if (!internal)
 			log_print_unless_silent("Using reduced mirror region size of %s",
 						display_size(cmd, region_size));
-                else
+		else
 			log_verbose("Using reduced mirror region size of %s",
 				    display_size(cmd, region_size));
 	}


