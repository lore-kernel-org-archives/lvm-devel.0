From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:47:38 -0500
Subject: master - cov: extent_size cannot be 0
Message-ID: <201812212047.wBLKlcMt021867@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26ead4bf45e94e6cfee2036d1c0c800abf4344b3
Commit:        26ead4bf45e94e6cfee2036d1c0c800abf4344b3
Parent:        9dfb1a11b76282ed8f3819bf63c369b179fac78d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 20:55:50 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:45:08 2018 +0100

cov: extent_size cannot be 0

Make this obvious to coverity.
---
 lib/metadata/cache_manip.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6cf945b..656e49d 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -1201,7 +1201,10 @@ int cache_single_set_params(struct cmd_context *cmd,
 	 * data size: the LV size minus the metadata size.
 	 */
 
-	extent_size = pool_lv->vg->extent_size;
+	if (!(extent_size = pool_lv->vg->extent_size)) {
+		log_error(INTERNAL_ERROR "Extend size can't be 0.");
+		return 0;
+	}
 	min_meta_size = extent_size;
 	max_meta_size = 2 * DEFAULT_CACHE_POOL_MAX_METADATA_SIZE; /* 2x for KiB to sectors */
 


