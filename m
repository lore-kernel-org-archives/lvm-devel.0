From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:04:23 -0400
Subject: master - snapshot: improve validation
Message-ID: <201710252004.v9PK4N7W029326@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e7edd1d2438bab5d08a8d3db47c082d9c4e0b12
Commit:        0e7edd1d2438bab5d08a8d3db47c082d9c4e0b12
Parent:        38f7fbac64ee8291776c168b32fbd39ce2706bfe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 24 16:34:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 21:58:01 2017 +0200

snapshot: improve validation

Do not allow to take snapshot of mirror/raid leg or log or metadata LV.
This was actually never supported, but user was able to create it,
and this put device stack in hardly fixable state (needs manual work).

This prevents such creation to pass.

Also improve validation when recreating snapshot volume type
from origin and COW volume.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    9 +++++++++
 tools/lvconvert.c       |    5 +++--
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3ba8e30..78a8052 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Disallow creation of snapshot of mirror/raid subLV (was never supported).
   Fix regression in more advanced vgname extraction in lvconvert (2.02.169).
   Allow lvcreate to be used for caching of _tdata LV.
   Avoid internal error when resizing cache type _tdata LV (not yet supported).
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b03f9cf..4cca5a1 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7622,11 +7622,20 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 			}
 
 			if (lv_is_mirror_type(origin_lv)) {
+				if (!lv_is_mirror(origin_lv)) {
+					log_error("Snapshots of mirror subvolumes are not supported.");
+					return NULL;
+				}
 				log_warn("WARNING: Snapshots of mirrors can deadlock under rare device failures.");
 				log_warn("WARNING: Consider using the raid1 mirror type to avoid this.");
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
+			if (lv_is_raid_type(origin_lv) && !lv_is_raid(origin_lv)) {
+				log_error("Snapshots of raid subvolumes are not supported.");
+				return NULL;
+			}
+
 			if (vg_is_clustered(vg) && lv_is_active(origin_lv) &&
 			    !lv_is_active_exclusive_locally(origin_lv)) {
 				log_error("%s must be active exclusively to"
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 02c649c..390a784 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1945,8 +1945,9 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	 * LV_foo specification because this LV is not processed by process_each_lv.
 	 */
 	if ((lv_is_cache_type(org) && !lv_is_cache(org)) ||
-	    lv_is_thin_type(org) ||
-	    lv_is_mirrored(org) ||
+	    (lv_is_thin_type(org) && !lv_is_thin_volume(org)) ||
+	    (lv_is_mirror_type(org) && !lv_is_mirror(org)) ||
+	    (lv_is_raid_type(org) && !lv_is_raid(org)) ||
 	    lv_is_cow(org)) {
 		log_error("Unable to use LV %s as snapshot origin: invald LV type.",
 			  display_lvname(lv));


