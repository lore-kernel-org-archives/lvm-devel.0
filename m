From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 May 2017 08:55:39 -0400
Subject: master - flags: add read and print of segtype flag
Message-ID: <201705291255.v4TCtdSM002373@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0299a7af1ec1eeb11388ed15c4c78f224fee76b2
Commit:        0299a7af1ec1eeb11388ed15c4c78f224fee76b2
Parent:        1bb0c5197f00594e50fb2b8a92f96633f32a9817
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 29 14:20:05 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 29 14:49:41 2017 +0200

flags: add read and print of segtype flag

Allow storing LV status bits with segment type name field.
Switching to this since this field has better support for compatibility
with older version of lvm2 - since such unknown segtype will not cause
complete invisiblity of metadata from older lvm2 code - just the
particular LV will become unusable with unknown type of segment.
---
 WHATS_NEW                       |    1 +
 lib/format_text/flags.c         |   58 +++++++++++++++++++++++++++++++++++++++
 lib/format_text/import-export.h |    3 ++
 3 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f38c23c..de65e0e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Support storing status flags via segtype name field.
   Stop using '--yes' mode when fsadm runs without terminal.
   Extend validation of filesystems resized by fsadm.
   Enhance lvconvert automatic settings of possible (raid) LV types.
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 871eeab..64bad1c 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -213,3 +213,61 @@ int read_flags(uint64_t *status, enum pv_vg_lv_e type, int mask, const struct dm
 	*status |= s;
 	return 1;
 }
+
+/*
+ * Parse extra status flags from segment "type" string.
+ * These flags are seen as INCOMPATIBLE by any older lvm2 code.
+ * All flags separated by '+' are trimmed from passed string.
+ * All UNKNOWN flags will again cause the "UNKNOWN" segtype.
+ *
+ * Note: using these segtype status flags instead of actual
+ * status flags ensures wanted incompatiblity.
+ */
+int read_segtype_lvflags(uint64_t *status, char *segtype_str)
+{
+	unsigned i;
+	const struct flag *flags = _lv_flags;
+	char *delim;
+	char *flag;
+
+	if (!(delim = strchr(segtype_str, '+')))
+		return 1; /* No flags */
+
+	*delim = '\0'; /* Cut away 1st. '+' */
+	do {
+		flag = delim + 1;
+		if ((delim = strchr(segtype_str, '+')))
+			*delim = '\0';
+
+		for (i = 0; flags[i].description; i++)
+			if ((flags[i].kind & SEGTYPE_FLAG) &&
+			    !strcmp(flags[i].description, flag)) {
+				*status |= flags[i].mask;
+				break;
+			}
+
+		if (!flags[i].description) {
+			log_error("Unknown flag %s passed with segment type %s.",
+				  flag, segtype_str);
+			return 0; /* Unknown flag is incompatible */
+		}
+	} while (delim); /* Till no more flags in type appear */
+
+	return 1;
+}
+
+int print_segtype_lvflags(char *buffer, size_t size, uint64_t status)
+{
+	unsigned i;
+	const struct flag *flags = _lv_flags;
+
+	buffer[0] = 0;
+	for (i = 0; flags[i].mask; i++)
+		if ((flags[i].kind & SEGTYPE_FLAG) &&
+		    (status & flags[i].mask) &&
+		    !emit_to_buffer(&buffer, &size, "+%s",
+				    flags[i].description))
+			return 0;
+
+	return 1;
+}
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index ddad50f..abb9b0e 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -62,6 +62,9 @@ struct text_vg_version_ops *text_vg_vsn1_init(void);
 int print_flags(char *buffer, size_t size, enum pv_vg_lv_e type, int mask, uint64_t status);
 int read_flags(uint64_t *status, enum pv_vg_lv_e type, int mask, const struct dm_config_value *cv);
 
+int print_segtype_lvflags(char *buffer, size_t size, uint64_t status);
+int read_segtype_lvflags(uint64_t *status, char *segtype_scr);
+
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
 struct volume_group *text_vg_import_file(struct format_instance *fid,


