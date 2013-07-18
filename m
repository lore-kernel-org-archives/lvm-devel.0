From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:35 +0000 (UTC)
Subject: master - snapshot: local activation for clear COW device
Message-ID: <20130718162635.5D4196073F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b4b97b731053ab2780d5ffdce5fc1c3e0626c2a
Commit:        7b4b97b731053ab2780d5ffdce5fc1c3e0626c2a
Parent:        b5dfe4bec2c5eb24559f650da47678ad1de527b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 18 16:20:48 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:43 2013 +0200

snapshot: local activation for clear COW device

To clear snapshot cow device in cluster enforce local
activation here.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ae725bb..641fd53 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Use local activation for clearing snapshot COW device.
   Add lvm2-activation-net systemd unit to activate LVs on net-attached storage.
   Release memory allocated with _cached_info().
   Add whole log_lv and metadata_lv sub volumes when creating partial tree.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7815e53..2e34a49 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5750,7 +5750,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 			}
 		}
 	} else if (lp->snapshot) {
-		if (!activate_lv_excl(cmd, lv)) {
+		if (!activate_lv_local(cmd, lv)) {
 			log_error("Aborting. Failed to activate snapshot "
 				  "exception store.");
 			goto revert_new_lv;


