From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Sep 2017 11:29:06 -0400
Subject: master - lvmlockd: always disallow mirror splitting
Message-ID: <201709051529.v85FT6BL024201@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3071837e21fae8907c1d584f9181e0589b9ce7e2
Commit:        3071837e21fae8907c1d584f9181e0589b9ce7e2
Parent:        09c792c20667aa8d7fb2799e484d913a5eb8a147
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 5 10:26:58 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 5 10:28:33 2017 -0500

lvmlockd: always disallow mirror splitting

lv_raid_split() was correctly prevented in a shared VG,
but lv_raid_split_and_track() was missing that check.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 32bbc41..e6cc18d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Prevent raid1 split with trackchanges in a shared VG.
   Avoid double unlocking of client & lockspace mutexes in lvmlockd.
   Fix leaking of file descriptor for non-blocking filebased locking.
   Fix check for 2nd mda at end of disk fits if using pvcreate --restorefile.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0432928..72223ca 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3426,6 +3426,12 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 	int s;
 	struct lv_segment *seg = first_seg(lv);
 
+	if (is_lockd_type(lv->vg->lock_type)) {
+		log_error("Splitting raid image is not allowed with lock_type %s.",
+			  lv->vg->lock_type);
+		return 0;
+	}
+
 	if (!seg_is_mirrored(seg)) {
 		log_error("Unable to split images from non-mirrored RAID.");
 		return 0;


