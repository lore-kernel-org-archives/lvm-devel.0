From: David Teigland <teigland@sourceware.org>
Date: Tue, 23 May 2017 18:00:45 -0400
Subject: master - add comment about PV in-use repair
Message-ID: <201705232200.v4NM0jCC023932@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a0f46e2f87f28e17c0ea6b6d58ffd90b37bc6f0
Commit:        7a0f46e2f87f28e17c0ea6b6d58ffd90b37bc6f0
Parent:        4d261cd719eb5c5f8b6d96adcb954c2e36c7c3ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 23 16:59:46 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 23 16:59:46 2017 -0500

add comment about PV in-use repair

copied from commit message for
d97f1c89deb9a75452059cd62ebb20cf7d2d6bfa
---
 lib/metadata/metadata.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 36bb0e4..c5a41fe 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3711,6 +3711,36 @@ struct _vg_read_orphan_baton {
 	int repair;
 };
 
+/*
+ * If we know that the PV is orphan, meaning there's at least one MDA on
+ * that PV which does not reference any VG and at the same time there's
+ * PV_EXT_USED flag set, we're certainly in an inconsistent state and we
+ * need to fix this.
+ *
+ * For example, such situation can happen during vgremove/vgreduce if we
+ * removed/reduced the VG, but we haven't written PV headers yet because
+ * vgremove stopped abruptly for whatever reason just before writing new
+ * PV headers with updated state, including PV extension flags (and so the
+ * PV_EXT_USED flag).
+ *
+ * However, in case the PV has no MDAs at all, we can't double-check
+ * whether the PV_EXT_USED is correct or not - if that PV is marked
+ * as used, it's either:
+ *  - really used (but other disks with MDAs are missing)
+ *  - or the error state as described above is hit
+ *
+ * User needs to overwrite the PV header directly if it's really clear
+ * the PV having no MDAs does not belong to any VG and at the same time
+ * it's still marked as being in use (pvcreate -ff <dev_name> will fix this).
+ *
+ * Note that the above doesn't account for the case where the PV has
+ * VG metadata that fails to be parsed.  In that case, the PV looks
+ * like an in-use orphan, and is auto-repaired here.  A PV with
+ * unparsable metadata should be kept on a special list of devices
+ * (like duplicate PVs) that are not auto-repaired, cannot be used
+ * by pvcreate, and are displayed with a special flag by 'pvs'.
+ */
+
 static int _check_or_repair_orphan_pv_ext(struct physical_volume *pv,
 					  struct lvmcache_info *info,
 					  struct _vg_read_orphan_baton *b)


