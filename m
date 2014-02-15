From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Feb 2014 10:39:05 +0000 (UTC)
Subject: master - cleanup: use struct initializer
Message-ID: <20140215103905.7A62C60E70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e2f70623351fe5de0e8179d377578a08b0a3625
Commit:        6e2f70623351fe5de0e8179d377578a08b0a3625
Parent:        a508786664f225d22c3549739abe7a749fc10960
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 14 21:36:56 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Feb 15 11:36:53 2014 +0100

cleanup: use struct initializer

---
 libdm/libdm-deptree.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 6d45e08..cede734 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -3110,14 +3110,13 @@ int dm_tree_node_add_raid_target(struct dm_tree_node *node,
 				 uint64_t rebuilds,
 				 uint64_t flags)
 {
-	struct dm_tree_node_raid_params params;
-
-	memset(&params, 0, sizeof(params));
-	params.raid_type = raid_type;
-	params.region_size = region_size;
-	params.stripe_size = stripe_size;
-	params.rebuilds = rebuilds;
-	params.flags = flags;
+	struct dm_tree_node_raid_params params = {
+		.raid_type = raid_type,
+		.region_size = region_size,
+		.stripe_size = stripe_size,
+		.rebuilds = rebuilds,
+		.flags = flags
+	};
 
 	return dm_tree_node_add_raid_target_with_params(node, size, &params);
 }


