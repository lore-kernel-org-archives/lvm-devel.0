From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Jun 2015 13:20:20 +0000 (UTC)
Subject: master - snapshot: add synchronization point
Message-ID: <20150624132020.37A1F611F4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e217873ed6ef7d77974fa10bfee4609160d7091d
Commit:        e217873ed6ef7d77974fa10bfee4609160d7091d
Parent:        cf189a572ae6fa6f7e00047925ebc965e57c6a8b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 24 15:12:43 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 24 15:18:49 2015 +0200

snapshot: add synchronization point

Synchronize with udev logic before reusing device as snapshot.

This patch tries to fix the problem with udev, where we manage
to 'active' LV for clearing, then we deactivate such device and
active again as member of 'origin&snapshot' tree all in 1 step.

There needs to be a sync point where udev has time to remove all links,
otherwise we race with scans and we may end-up with mysterious 'free'
links in the system pointing to wrong dm names.

This patch tries to fix failing topology cluster tests..
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 94766af..34f4cf0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.123 - 
 =================================
+  Add device synchronization point before activating a new snapshot.
   Add --withspaces to lvmconfig to add spaces in output for better readability.
 
 Version 2.02.122 - 20th June 2015
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 07f119a..de96743 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7446,6 +7446,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			goto deactivate_and_revert_new_lv; /* Let's retry on error path */
 		}
 
+		/* Get in sync with deactivation, before reusing LV as snapshot */
+		sync_local_dev_names(lv->vg->cmd);
+
 		/* Create zero origin volume for spare snapshot */
 		if (lp->virtual_extents &&
 		    !(origin_lv = _create_virtual_origin(cmd, vg, lv->name,


