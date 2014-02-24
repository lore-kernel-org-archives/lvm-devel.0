From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:18 +0000 (UTC)
Subject: master - cleanup: indent, drop unneeded braces
Message-ID: <20140224201718.EC88F60FC0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a920bc1a40f3d8d76d0109ecfc6559965b458986
Commit:        a920bc1a40f3d8d76d0109ecfc6559965b458986
Parent:        408e276a615faf22e829cea385738dce02edae26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 22 23:13:43 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:35 2014 +0100

cleanup: indent, drop unneeded braces

---
 libdm/libdm-deptree.c |    6 ++++--
 tools/lvconvert.c     |    1 +
 tools/toollib.c       |    2 +-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index fad14d6..e513885 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1626,7 +1626,9 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 				  info.minor);
 			r = 0;
 			continue;
-		} else if (info.suspended && info.live_table)
+		}
+
+		if (info.suspended && info.live_table)
 			dec_suspended();
 
 		if (child->callback &&
@@ -2705,7 +2707,7 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 				  child->info.minor);
 			/* If the device was not previously active, we might as well remove this node. */
 			if (!child->info.live_table &&
-			    !_deactivate_node(child->name, child->info.major,child->info.minor,
+			    !_deactivate_node(child->name, child->info.major, child->info.minor,
 					      &child->dtree->cookie, child->udev_flags, 0))
 				log_error("Unable to deactivate %s (%" PRIu32
 					  ":%" PRIu32 ")", child->name, child->info.major,
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 814ac65..09a64c7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3134,6 +3134,7 @@ static int _poll_logical_volume(struct cmd_context *cmd, struct logical_volume *
 		log_print_unless_silent("Conversion starts after activation.");
 		return ECMD_PROCESSED;
 	}
+
 	return lvconvert_poll(cmd, lv, wait_completion ? 0 : 1U);
 }
 
diff --git a/tools/toollib.c b/tools/toollib.c
index 31033e6..91b0559 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -681,7 +681,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 			if (sigint_caught())
 				return_ECMD_FAILED;
 			vgid = sl->str;
-			if (!(vgid) || !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
+			if (!vgid || !(vg_name = lvmcache_vgname_from_vgid(cmd->mem, vgid)))
 				continue;
 			ret_max = _process_one_vg(cmd, vg_name, vgid, &tagsl,
 						  &arg_vgnames,


