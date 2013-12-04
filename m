From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 16:10:42 +0000 (UTC)
Subject: master - vgchange: move detection of remote exlusivness
Message-ID: <20131204161042.2533760EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=598c82fc077c8a3edfbdb664b41efd89d05b5a10
Commit:        598c82fc077c8a3edfbdb664b41efd89d05b5a10
Parent:        28939dba09fcd36cd0e4e470e73b172f19dd45e8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 28 23:22:03 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 17:09:51 2013 +0100

vgchange: move detection of remote exlusivness

Since activation takes only read-lock, there could be
multiple activation running in parallel.

So instead of checking before taking any real lock,
let the locking resolve the problem and just
detect if the reason for failure has been remote
exlusive activation.

It should be also faster, since each activation does
not need to do explicit lock query.
---
 WHATS_NEW        |    1 +
 tools/vgchange.c |   22 +++++++++++-----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d41700..60571ff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Test for remote exclusive activation after activation fails.
   Support lvconvert --merge for thin snapshots.
   Add support to read thin device id from table line entry.
   Drop extra test for origin when testing merging origin in lv_refresh().
diff --git a/tools/vgchange.c b/tools/vgchange.c
index b50b444..f9811d2 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -121,16 +121,6 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		    ((lv->status & PVMOVE) ))
 			continue;
 
-		/*
-		 * If the LV is active exclusive remotely,
-		 * then ignore it here
-		 */
-		if (lv_is_active_exclusive_remotely(lv)) {
-			log_verbose("%s/%s is exclusively active on"
-				    " a remote node", vg->name, lv->name);
-			continue;
-		}
-
 		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0)) {
 			log_verbose("ACTIVATION_SKIP flag set for LV %s/%s, skipping activation.",
 				    lv->vg->name, lv->name);
@@ -144,7 +134,17 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		expected_count++;
 
 		if (!lv_change_activate(cmd, lv, activate)) {
-			stack;
+			if (!lv_is_active_exclusive_remotely(lv))
+				stack;
+			else {
+				/*
+				 * If the LV is active exclusive remotely,
+				 * then ignore it here
+				 */
+				log_verbose("%s/%s is exclusively active on"
+					    " a remote node", vg->name, lv->name);
+				expected_count--; /* not accounted */
+			}
 			continue;
 		}
 


