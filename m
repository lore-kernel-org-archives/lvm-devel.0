From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:53 +0000 (UTC)
Subject: master - format: format_text: add pv_needs_rewrite to format_handler and implemention for format_text
Message-ID: <20160215120853.2CE1960DDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b9f1ae7726c2ee0e7eda76cd519f7d4921a12d9
Commit:        9b9f1ae7726c2ee0e7eda76cd519f7d4921a12d9
Parent:        08de88535e4b06906507abf7ab79bf26be6469f8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 13:53:06 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

format: format_text: add pv_needs_rewrite to format_handler and implemention for format_text

---
 lib/format_text/format-text.c |   22 ++++++++++++++++++++++
 lib/metadata/metadata.h       |    9 +++++++++
 2 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 7202658..666357c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1439,6 +1439,27 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 	return 1;
 }
 
+static int _text_pv_needs_rewrite(const struct format_type *fmt, struct physical_volume *pv,
+				  int *needs_rewrite)
+{
+	struct lvmcache_info *info;
+	uint32_t ext_vsn;
+
+	*needs_rewrite = 0;
+
+	if (!(info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
+		log_error("Failed to find cached info for PV %s.", pv_dev_name(pv));
+		return 0;
+	}
+
+	ext_vsn = lvmcache_ext_version(info);
+
+	if (ext_vsn < PV_HEADER_EXTENSION_VSN)
+		*needs_rewrite = 1;
+
+	return 1;
+}
+
 static int _add_raw(struct dm_list *raw_list, struct device_area *dev_area)
 {
 	struct raw_list *rl;
@@ -2384,6 +2405,7 @@ static struct format_handler _text_handler = {
 	.pv_remove_metadata_area = _text_pv_remove_metadata_area,
 	.pv_resize = _text_pv_resize,
 	.pv_write = _text_pv_write,
+	.pv_needs_rewrite = _text_pv_needs_rewrite,
 	.vg_setup = _text_vg_setup,
 	.lv_setup = _text_lv_setup,
 	.create_instance = _text_create_text_instance,
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 3f5f5ae..f2b62e4 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -303,6 +303,15 @@ struct format_handler {
 			 struct physical_volume * pv);
 
 	/*
+	 * Check if PV needs rewriting. This is used to check whether there are any
+	 * format-specific changes  before actually writing the PV (by calling pv_write).
+	 * With this, we can call pv_write conditionally only if it's really needed.
+	 */
+	int (*pv_needs_rewrite) (const struct format_type *fmt,
+				 struct physical_volume *pv,
+				 int *needs_rewrite);
+
+	/*
 	 * Tweak an already filled out a lv eg, check there
 	 * aren't too many extents.
 	 */


