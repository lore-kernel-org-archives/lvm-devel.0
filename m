From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Sep 2014 11:51:47 +0000 (UTC)
Subject: master - thin: check for active lv
Message-ID: <20140915115147.E26F160D6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=75a5de1462c30f364c7d478a4f74f355ce559ae9
Commit:        75a5de1462c30f364c7d478a4f74f355ce559ae9
Parent:        ef6508e9a4ca7e9e2827b59c3e22f6442dcc72d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 15 13:42:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 15 13:51:19 2014 +0200

thin: check for active lv

Before calling deactivate, check the lv is actually active,
as we may reach this 'bad' error path with pool_lv inactive.
---
 WHATS_NEW                 |    1 +
 lib/metadata/pool_manip.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ac9d9a5..c48b979 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Avoid leaving linear logical volume when thin pool creation fails.
   Demote an error to a warning when devices known to lvmetad are filtered out.
   Re-order filter evaluation, making component filters global.
   Don't leak alloc_handle on raid target error path.
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 0ed5d64..0c66c77 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -450,7 +450,8 @@ int create_pool(struct logical_volume *pool_lv,
 
 bad:
 	if (activation()) {
-		if (deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
+		if (lv_is_active_locally(pool_lv) &&
+		    deactivate_lv_local(pool_lv->vg->cmd, pool_lv)) {
 			log_error("Aborting. Could not deactivate pool %s.",
 				  pool_lv->name);
 			return 0;


