From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 May 2016 16:41:29 +0000 (UTC)
Subject: master - libdm: cache status reports passthrough cache mode
Message-ID: <20160519164129.C552B602F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e8ba5c9bd4f8a1ff5d67b597c10eea3d176b27e1
Commit:        e8ba5c9bd4f8a1ff5d67b597c10eea3d176b27e1
Parent:        e694e0896bd4d320f5d5017411763583698b28dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 19 18:20:11 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 19 18:26:07 2016 +0200

libdm: cache status reports passthrough cache mode

Report passthrough mode instead of 'Unknown feature'.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-targets.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b6703c7..d446997 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.126 - 
 ================================
+  Report passthrough caching mode when parsing cache mode.
 
 Version 1.02.125 - 14th May 2016
 ================================
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index b91c7e9..c94e057 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -256,6 +256,8 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			s->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
 		else if (!strncmp(p, "writeback ", 10))
 			s->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
+		else if (!strncmp(p, "passthrough ", 11))
+			s->feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
 		else
 			log_error("Unknown feature in status: %s", params);
 


