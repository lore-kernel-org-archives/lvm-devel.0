From: okozina <okozina@fedoraproject.org>
Date: Mon, 13 Apr 2015 18:53:56 +0000 (UTC)
Subject: master - vgchange: remove redundant check
Message-ID: <20150413185356.615AE60FCD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59c417379e067f85cd962c2024f7a042f04a41fd
Commit:        59c417379e067f85cd962c2024f7a042f04a41fd
Parent:        fa16c9b7cbe5a4d71452247765142c670b3b0e31
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Apr 8 10:30:30 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Apr 13 20:52:12 2015 +0200

vgchange: remove redundant check

pvmove LVs are invisible thus already skipped due to check
lv_is_visible() at the beginning of the cycle.
---
 tools/vgchange.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 88a85d8..1665d3e 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -114,11 +114,6 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (lv_is_replicator_dev(lv) && (lv != first_replicator_dev(lv)))
 			continue;
 
-		/* Can't deactivate a pvmove LV */
-		/* FIXME There needs to be a controlled way of doing this */
-		if (lv_is_pvmove(lv) && !is_change_activating(activate))
-			continue;
-
 		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG)))
 			continue;
 


