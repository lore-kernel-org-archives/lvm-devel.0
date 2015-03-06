From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  6 Mar 2015 13:31:35 +0000 (UTC)
Subject: master - lib: return value
Message-ID: <20150306133135.C16AC606F1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60427d5d429b88d1c6cd13f90794f9b50dc366e6
Commit:        60427d5d429b88d1c6cd13f90794f9b50dc366e6
Parent:        4d16bfaabb5d72009e80cb6f5bc0d650101ebb33
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 6 09:04:31 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 6 13:51:43 2015 +0100

lib: return value

Drop label out: with goto and return NULL directly.
Add log_debug() for zero metadata offset.
---
 lib/format_text/format-text.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c142e1b..375a793 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1142,7 +1142,7 @@ const char *vgname_from_mda(const struct format_type *fmt,
 
 	if (!mdah) {
 		log_error(INTERNAL_ERROR "vgname_from_mda called with NULL pointer for mda_header");
-		goto_out;
+		return NULL;
 	}
 
 	/* FIXME Cope with returning a list */
@@ -1151,13 +1151,16 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	/*
 	 * If no valid offset, do not try to search for vgname
 	 */
-	if (!rlocn->offset)
-		goto out;
+	if (!rlocn->offset) {
+		log_debug("%s: found metadata with offset 0.",
+			  dev_name(dev_area->dev));
+		return NULL;
+	}
 
 	/* Do quick check for a vgname */
 	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
 		      NAME_LEN, buf))
-		goto_out;
+		return_NULL;
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -1167,7 +1170,7 @@ const char *vgname_from_mda(const struct format_type *fmt,
 
 	/* Ignore this entry if the characters aren't permissible */
 	if (!validate_name(buf))
-		goto_out;
+		return_NULL;
 
 	/* We found a VG - now check the metadata */
 	if (rlocn->offset + rlocn->size > mdah->size)
@@ -1176,7 +1179,7 @@ const char *vgname_from_mda(const struct format_type *fmt,
 	if (wrap > rlocn->offset) {
 		log_error("%s: metadata too large for circular buffer",
 			  dev_name(dev_area->dev));
-		goto out;
+		return NULL;
 	}
 
 	/* FIXME 64-bit */
@@ -1188,18 +1191,14 @@ const char *vgname_from_mda(const struct format_type *fmt,
 						   MDA_HEADER_SIZE),
 					  wrap, calc_crc, rlocn->checksum,
 					  vgid, vgstatus, creation_host)))
-		goto_out;
+		return_NULL;
 
 	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(vgname)) {
-		vgname = NULL;
-		goto_out;
-	}
+	if (!validate_name(vgname))
+		return_NULL;
 
-	if (!id_write_format(vgid, uuid, sizeof(uuid))) {
-		vgname = NULL;
-		goto_out;
-	}
+	if (!id_write_format(vgid, uuid, sizeof(uuid)))
+		return_NULL;
 
 	log_debug_metadata("%s: Found metadata at %" PRIu64 " size %" PRIu64
 			   " (in area at %" PRIu64 " size %" PRIu64
@@ -1218,7 +1217,6 @@ const char *vgname_from_mda(const struct format_type *fmt,
 			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
 	}
 
-      out:
 	return vgname;
 }
 


