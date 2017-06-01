From: David Teigland <teigland@sourceware.org>
Date: Thu, 1 Jun 2017 10:53:31 -0400
Subject: master - disable repairing in-use flag on orphan PVs
Message-ID: <201706011453.v51ErVJx013196@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f3c90e90f8466b5c2fe336e9a1947307c92c9e59
Commit:        f3c90e90f8466b5c2fe336e9a1947307c92c9e59
Parent:        743ffb1962ef272e5023c1ac652c5bcde86ff5fd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 26 13:26:09 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 1 09:53:14 2017 -0500

disable repairing in-use flag on orphan PVs

A PV holding VG metadata that lvm can't understand
(e.g. damaged, checksum error, unrecognized flag)
will appear as an in-use orphan, and will be cleared
by this repair code.  Disable this repair until the
code can keep track of these problematic PVs, and
distinguish them from actual in-use orphans.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 878aa7a..10d845f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Disable automatic clearing of PVs that look like in-use orphans.
   Cache format2 flag is now using segment name type field.
   Support storing status flags via segtype name field.
   Stop using '--yes' mode when fsadm runs without terminal.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c5a41fe..cb02ecf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3741,6 +3741,7 @@ struct _vg_read_orphan_baton {
  * by pvcreate, and are displayed with a special flag by 'pvs'.
  */
 
+#if 0
 static int _check_or_repair_orphan_pv_ext(struct physical_volume *pv,
 					  struct lvmcache_info *info,
 					  struct _vg_read_orphan_baton *b)
@@ -3794,6 +3795,7 @@ static int _check_or_repair_orphan_pv_ext(struct physical_volume *pv,
 
 	return 1;
 }
+#endif
 
 static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 {
@@ -3815,10 +3817,25 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 	pvl->pv = pv;
 	add_pvl_to_vgs(b->vg, pvl);
 
+	/*
+	 * FIXME: this bit of code that does the auto repair is disabled
+	 * until we can distinguish cases where the repair should not
+	 * happen, i.e. the VG metadata could not be read/parsed.
+	 *
+	 * A PV holding VG metadata that lvm can't understand
+	 * (e.g. damaged, checksum error, unrecognized flag)
+	 * will appear as an in-use orphan, and would be cleared
+	 * by this repair code.  Disable this repair until the
+	 * code can keep track of these problematic PVs, and
+	 * distinguish them from actual in-use orphans.
+	 */
+
+	/*
 	if (!_check_or_repair_orphan_pv_ext(pv, info, baton)) {
 		stack;
 		return 0;
 	}
+	*/
 
 	return 1;
 }


