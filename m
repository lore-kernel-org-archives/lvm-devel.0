From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Jun 2017 06:03:33 -0400
Subject: master - cleanup: use DM limit define
Message-ID: <201706081003.v58A3XtA007762@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba3d3210d7fb2ad0379b90869c1e38167346091b
Commit:        ba3d3210d7fb2ad0379b90869c1e38167346091b
Parent:        719d0996930dfad8608c49af2f81008b6ca77cb8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 5 11:26:01 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 8 11:07:58 2017 +0200

cleanup: use DM limit define

For calculation use already defined size in libdm, which give better
estimation of maximal size of thin pool metadata.
---
 lib/config/defaults.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 05747fa..51542df 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -104,7 +104,7 @@
 #define DEFAULT_THIN_REPAIR_OPTION1 ""
 #define DEFAULT_THIN_REPAIR_OPTIONS_CONFIG "#S" DEFAULT_THIN_REPAIR_OPTION1
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
-#define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
+#define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (DM_THIN_MAX_METADATA_SIZE / 2)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
 #define DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE (128 * 1024 * 1024) /* KB */
 #define DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY "generic"


