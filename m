From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  6 Apr 2016 09:55:34 +0000 (UTC)
Subject: master - suspend: fix suspend with noflush limitation
Message-ID: <20160406095534.4E3356112E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c1937f8df1e843d00b9d5814c756234381ca0d1
Commit:        7c1937f8df1e843d00b9d5814c756234381ca0d1
Parent:        d4c03cf7b21279ad28b8b9944d0281a55692efcc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 6 10:29:05 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 6 11:31:02 2016 +0200

suspend: fix suspend with noflush limitation

Commit 844b00958492224c448b30f89ae5532bb6591fd2 tried to move
limit for usage of noflush to 'preload' however this was not
correctly processed.

Intead explicitly check for which types we do not want noflush
and also add debug message in this case.
---
 lib/activate/activate.c    |   10 ++++++++++
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a3b2379..7afb439 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1933,6 +1933,16 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		}
 	}
 
+	/* Flush is ATM required for the tested cases
+	 * NOTE: Mirror repair requires noflush for proper repair!
+	 * TODO: Relax this limiting condition further */
+	if (!flush_required &&
+	    (lv_is_pvmove(lv) ||
+	     (!lv_is_mirror(lv) && !lv_is_thin_pool(lv) && !lv_is_thin_volume(lv)))) {
+		log_debug("Requiring flush for LV %s.", display_lvname(lv));
+		flush_required = 1;
+	}
+
 	if (!monitor_dev_for_events(cmd, lv, laopts, 0))
 		/* FIXME Consider aborting here */
 		stack;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 22331c3..994ba80 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3023,7 +3023,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if (!dm->flush_required && !lv_is_pvmove(lv))
+		if (!dm->flush_required)
 			dm_tree_use_no_flush_suspend(root);
 		/* Fall through */
 	case SUSPEND_WITH_LOCKFS:


