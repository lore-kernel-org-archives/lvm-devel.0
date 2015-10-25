From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 25 Oct 2015 20:10:00 +0000 (UTC)
Subject: master - dev_manager: enabled no_flush for suspend
Message-ID: <20151025201000.EE41C609CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=844b00958492224c448b30f89ae5532bb6591fd2
Commit:        844b00958492224c448b30f89ae5532bb6591fd2
Parent:        9ef820a2a5e174cd08097981d7879e1f4cbded01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 20:37:39 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 25 21:07:37 2015 +0100

dev_manager: enabled no_flush for suspend

While the activation code tries to evaluate which target
really needs flush with suspend and which may go without flush,
it has stayed effectively disabled by original commit:
33f732c5e9493cda4b161a18b3d53885d207e3b8 since here
it only allows to pass non-pvmoving  'mirrors'.

So remove check for mirror LV type and only disable
no_flush for 'pvmove'..

TODO: Looking into history - it also seemed like raid target
would have always required flushing but it's been later
removed without clean explanation.

If some more targets really do need 'no_flush' it should
been handle at their 'level' - since we now stack multiple
targets over itself.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8ca0aa7..33d11a4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.133 - 
 ======================================
+  Enable code which detects the need of flush during suspend.
   Ensure --use-policy will resize volume to fit below threshold.
   Correct percentage evaluation when checking thin-pool over threshold.
   Fix lvmcache to move PV from VG to orphans if VG is removed and lvmetad used.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a5ee824..1caa2d7 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3277,7 +3277,7 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		break;
 	case SUSPEND:
 		dm_tree_skip_lockfs(root);
-		if (!dm->flush_required && lv_is_mirror(lv) && !lv_is_pvmove(lv))
+		if (!dm->flush_required && !lv_is_pvmove(lv))
 			dm_tree_use_no_flush_suspend(root);
 		/* Fall through */
 	case SUSPEND_WITH_LOCKFS:


