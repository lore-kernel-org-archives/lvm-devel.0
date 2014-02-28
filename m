From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:31 +0000 (UTC)
Subject: master - lvmetad: Hide corrupt MDAs from the cache.
Message-ID: <20140228102631.0FBB060FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a36869867275b8ef0f6d324bc5a7f3e2b8e445e9
Commit:        a36869867275b8ef0f6d324bc5a7f3e2b8e445e9
Parent:        6b43db580474ae96627c6b3784c136b56f30dde3
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Thu Feb 27 23:06:42 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

lvmetad: Hide corrupt MDAs from the cache.

This is probably not optimal, but makes the lvmetad case mimic non-lvmetad code
more closely. It also fixes vgremove of a partially corrupt VG with lvmetad, as
_vg_write_raw (and consequently, entire vg_write) currently panics when it
encounters a corrupt MDA. Ideally, we'd be able to explicitly control when it is
safe to ignore them.
---
 lib/format_text/format-text.c     |   47 +++++++++++++++++++++++-------------
 test/shell/vgremove-corrupt-vg.sh |   20 +++++++++++++++
 2 files changed, 50 insertions(+), 17 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index b4f96f8..0d6483a 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -316,18 +316,13 @@ static void _xlate_mdah(struct mda_header *mdah)
 	}
 }
 
-struct mda_header *raw_read_mda_header(const struct format_type *fmt,
-				       struct device_area *dev_area)
+static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area)
 {
-	struct mda_header *mdah;
-
-	if (!(mdah = dm_pool_alloc(fmt->cmd->mem, MDA_HEADER_SIZE))) {
-		log_error("struct mda_header allocation failed");
-		return NULL;
-	}
+	if (!dev_open(dev_area->dev))
+		return_0;
 
 	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, mdah))
-		goto_bad;
+		return_0;
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
@@ -335,7 +330,7 @@ struct mda_header *raw_read_mda_header(const struct format_type *fmt,
 		log_error("Incorrect metadata area header checksum on %s"
 			  " at offset %"PRIu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		goto bad;
+		return 0;
 	}
 
 	_xlate_mdah(mdah);
@@ -344,28 +339,42 @@ struct mda_header *raw_read_mda_header(const struct format_type *fmt,
 		log_error("Wrong magic number in metadata area header on %s"
 			  " at offset %"PRIu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		goto bad;
+		return 0;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
 		log_error("Incompatible metadata area header version: %d on %s"
 			  " at offset %"PRIu64, mdah->version,
 			  dev_name(dev_area->dev), dev_area->start);
-		goto bad;
+		return 0;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: %"
 			  PRIu64" on %s at offset %"PRIu64, mdah->start,
 			  dev_name(dev_area->dev), dev_area->start);
-		goto bad;
+		return 0;
 	}
 
-	return mdah;
+	return 1;
+}
 
-bad:
-	dm_pool_free(fmt->cmd->mem, mdah);
-	return NULL;
+struct mda_header *raw_read_mda_header(const struct format_type *fmt,
+				       struct device_area *dev_area)
+{
+	struct mda_header *mdah;
+
+	if (!(mdah = dm_pool_alloc(fmt->cmd->mem, MDA_HEADER_SIZE))) {
+		log_error("struct mda_header allocation failed");
+		return NULL;
+	}
+
+	if (!_raw_read_mda_header(mdah, dev_area)) {
+		dm_pool_free(fmt->cmd->mem, mdah);
+		return NULL;
+	}
+
+	return mdah;
 }
 
 static int _raw_write_mda_header(const struct format_type *fmt,
@@ -1670,6 +1679,10 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 				struct dm_config_node *parent)
 {
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
+	char mdah[MDA_HEADER_SIZE]; /* temporary */
+
+	if (!mdc || !_raw_read_mda_header(mdah, &mdc->area))
+		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,
 				 "ignore = %" PRId64, (int64_t) mda_is_ignored(mda),
diff --git a/test/shell/vgremove-corrupt-vg.sh b/test/shell/vgremove-corrupt-vg.sh
new file mode 100644
index 0000000..9e750ac
--- /dev/null
+++ b/test/shell/vgremove-corrupt-vg.sh
@@ -0,0 +1,20 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 3
+lvcreate -n blabla -L 1 $vg -an --zero n
+
+dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
+aux notify_lvmetad "$dev2"
+
+vgremove -f $vg


