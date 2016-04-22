From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Apr 2016 10:54:38 +0000 (UTC)
Subject: master - cache: fix previous change and correct ()
Message-ID: <20160422105438.ADD2E61B98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4ddf5a11cf333fdcf45eec907e12e10c41a9d578
Commit:        4ddf5a11cf333fdcf45eec907e12e10c41a9d578
Parent:        17ad8848361aa16ff227038068c3d0771771f095
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 12:31:02 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 12:52:53 2016 +0200

cache: fix previous change and correct ()

412f09ca332c644e08421e289a3e8d54890971ba missed parentheses.
---
 lib/metadata/cache_manip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 1c51f66..46cb6a8 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -47,11 +47,10 @@ const char *get_cache_mode_name(const struct lv_segment *seg)
 	if (seg->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
 		return "writeback";
 
-	if (!seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH) {
+	if (!(seg->feature_flags & DM_CACHE_FEATURE_WRITETHROUGH))
 		log_error(INTERNAL_ERROR "LV %s has uknown feature flags %" PRIu64 ", "
 			  "returning writethrough instead.",
 			  display_lvname(seg->lv), seg->feature_flags);
-	}
 
 	return "writethrough";
 }


