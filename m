From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:03:22 +0000 (UTC)
Subject: master - libdm: enforce writethrough mode for cleaner
Message-ID: <20151013140322.BD7CE60E41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5695c6aca63b2312e76f8b3fbbea95601269f8c8
Commit:        5695c6aca63b2312e76f8b3fbbea95601269f8c8
Parent:        5ac81657e5d312b72d746bc7cf22a4e6bb5b1609
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 13 14:06:15 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 14:35:48 2015 +0200

libdm: enforce writethrough mode for cleaner

With "cleaner" policy always use 'writethrough' mode.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e89ead0..e760875 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Enforce writethrough mode for cleaner policy.
   Add support for recognition and deactivation of MD devices to blkdeactivate.
   Move target status functions out of libdm-deptree.
   Correct use of max_write_behind parameter when generating raid target line.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ef283e9..afdce8d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3302,7 +3302,8 @@ int dm_tree_node_add_cache_target(struct dm_tree_node *node,
 		return_0;
 
 	seg->data_block_size = data_block_size;
-	seg->flags = feature_flags;
+	/* Enforce WriteThough mode for cleaner policy */
+	seg->flags = (strcmp(policy_name, "cleaner") == 0) ? DM_CACHE_FEATURE_WRITETHROUGH : feature_flags;
 	seg->policy_name = policy_name;
 
 	/* FIXME: better validation missing */


