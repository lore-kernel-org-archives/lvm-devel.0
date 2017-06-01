From: David Teigland <teigland@sourceware.org>
Date: Thu, 1 Jun 2017 12:20:00 -0400
Subject: master - print warning about in-use orphans
Message-ID: <201706011620.v51GK0nn026131@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c98a25aab1659a5640ac473517bb6af97d696588
Commit:        c98a25aab1659a5640ac473517bb6af97d696588
Parent:        f3c90e90f8466b5c2fe336e9a1947307c92c9e59
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 1 11:10:09 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 1 11:18:42 2017 -0500

print warning about in-use orphans

Warn about a PV that has the in-use flag set, but appears in
the orphan VG (no VG was found referencing it.)

There are a number of conditions that could lead to this:

. The PV was created with no mdas and is used in a VG with
  other PVs (with metadata) that have not yet appeared on
  the system.  So, no VG metadata is found by lvm which
  references the in-use PV with no mdas.

. vgremove could have failed after clearing mdas but
  before clearing the in-use flag.  In this case, the
  in-use flag needs to be manually cleared on the PV.

. The PV may have damanged/unrecognized VG metadata
  that lvm could not read.

. The PV may have no mdas, and the PVs with the metadata
  may have damaged/unrecognized metadata.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 10d845f..ae704af 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Print a warning about in-use PVs with no VG using them.
   Disable automatic clearing of PVs that look like in-use orphans.
   Cache format2 flag is now using segment name type field.
   Support storing status flags via segtype name field.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index cb02ecf..4ba81c7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3802,6 +3802,8 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 	struct _vg_read_orphan_baton *b = baton;
 	struct physical_volume *pv = NULL;
 	struct pv_list *pvl;
+	uint32_t ext_version;
+	uint32_t ext_flags;
 
 	if (!(pv = _pv_read(b->vg->cmd, b->vg->vgmem, dev_name(lvmcache_device(info)),
 			    b->vg->fid, b->warn_flags, 0))) {
@@ -3837,6 +3839,40 @@ static int _vg_read_orphan_pv(struct lvmcache_info *info, void *baton)
 	}
 	*/
 
+	/*
+	 * Nothing to do if PV header extension < 2:
+	 *  - version 0 is PV header without any extensions,
+	 *  - version 1 has bootloader area support only and
+	 *    we're not checking anything for that one here.
+	 */
+	ext_version = lvmcache_ext_version(info);
+	ext_flags = lvmcache_ext_flags(info);
+
+	/*
+	 * Warn about a PV that has the in-use flag set, but appears in
+	 * the orphan VG (no VG was found referencing it.)
+	 * There are a number of conditions that could lead to this:
+	 *
+	 * . The PV was created with no mdas and is used in a VG with
+	 * other PVs (with metadata) that have not yet appeared on
+	 * the system.  So, no VG metadata is found by lvm which
+	 * references the in-use PV with no mdas.
+	 *
+	 * . vgremove could have failed after clearing mdas but
+	 * before clearing the in-use flag.  In this case, the
+	 * in-use flag needs to be manually cleared on the PV.
+	 *
+	 * . The PV may have damanged/unrecognized VG metadata
+	 * that lvm could not read.
+	 *
+	 * . The PV may have no mdas, and the PVs with the metadata
+	 * may have damaged/unrecognized metadata.
+	 */
+	if ((ext_version >= 2) && (ext_flags & PV_EXT_USED)) {
+		log_warn("WARNING: PV %s is marked in use but no VG was found using it.", pv_dev_name(pv));
+		log_warn("WARNING: PV %s might need repairing.", pv_dev_name(pv));
+	}
+
 	return 1;
 }
 


