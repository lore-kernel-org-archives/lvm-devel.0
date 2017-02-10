From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 10 Feb 2017 19:31:57 +0000 (UTC)
Subject: master - libdm: avoid resume if preloaded device is smaller
Message-ID: <20170210193157.59DC46070B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c908a8b131d0ae12cf87a271b10dfeaf65d4e0a7
Commit:        c908a8b131d0ae12cf87a271b10dfeaf65d4e0a7
Parent:        035c614c195b08398df3403c4bbd3d986cca68c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 19:57:04 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 20:29:11 2017 +0100

libdm: avoid resume if preloaded device is smaller

When we preload device with smaller size, we avoid its resume,
so later suspend/resume of full device tree my process all
existing in flight bios.

Also update comment and avoid using confusing opposite meaning.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ac2d420..47f647a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Avoids immediate resume when preloaded device is smaller.
   Do not suppress kernel key description in dmsetup table output.
   Support configurable command executed from dmeventd thin plugin.
   Support new R|r human readable units output format.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 9570b8a..d658bf9 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2874,8 +2874,8 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 		else if (child->props.size_changed < 0)
 			dnode->props.size_changed = -1;
 
-		/* Resume device immediately if it has parents and its size changed */
-		if (!dm_tree_node_num_children(child, 1) || !child->props.size_changed)
+		/* No resume for a device without parents or with unchanged or smaller size */
+		if (!dm_tree_node_num_children(child, 1) || (child->props.size_changed <= 0))
 			continue;
 
 		if (!node_created && (dm_list_size(&child->props.segs) == 1)) {


