From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:01 +0000 (UTC)
Subject: master - pool: fix testmode support with pools
Message-ID: <20141024144001.68CEF60E3E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2244c37764f8481fedd7d4b5f286665e9d46af2
Commit:        a2244c37764f8481fedd7d4b5f286665e9d46af2
Parent:        1c7aae40a1bb1351680ec8c7afa12c2bf8b784a0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 15:03:24 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

pool: fix testmode support with pools

Allow the --test mode to proceed further.
---
 WHATS_NEW                 |    1 +
 lib/metadata/pool_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3b52595..b197568 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Better support for --test mode with pool creation.
   Query lock holding LV when replacing and converting raid volumes.
   Add extra validate for locked lv within validate_lv_cache_create().
   Add internal lvseg_name() function.
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 4c0ab72..011d9c0 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -415,7 +415,7 @@ int create_pool(struct logical_volume *pool_lv,
 	if (!activation())
 		log_warn("WARNING: Pool %s is created without initialization.",
 			 pool_lv->name);
-	else {
+	else if (!test_mode()) {
 		if (!vg_write(pool_lv->vg) || !vg_commit(pool_lv->vg))
 			return_0;
 


