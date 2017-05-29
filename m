From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 29 May 2017 08:55:28 -0400
Subject: master - cleanup: separate type and mask
Message-ID: <201705291255.v4TCtScl002349@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=966d1130dbf1e9da5ae0b432296741ba4ad35b6a
Commit:        966d1130dbf1e9da5ae0b432296741ba4ad35b6a
Parent:        8e0bc73eba4db74cb92fe884687f1cbfd4b20930
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 26 15:47:17 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 29 14:47:26 2017 +0200

cleanup: separate type and mask

Split misused 'enum' into 2 fields - one for type
of PV, VG, LV and other for mask.
---
 lib/format_text/export.c        |    5 +++--
 lib/format_text/flags.c         |   15 ++++++++-------
 lib/format_text/import-export.h |   13 +++++++------
 lib/format_text/import_vsn1.c   |    4 ++--
 4 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index f530ec9..829b46d 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -358,11 +358,12 @@ static int _print_header(struct cmd_context *cmd, struct formatter *f,
 static int _print_flag_config(struct formatter *f, uint64_t status, int type)
 {
 	char buffer[4096];
-	if (!print_flags(status, type | STATUS_FLAG, buffer, sizeof(buffer)))
+
+	if (!print_flags(buffer, sizeof(buffer), type, STATUS_FLAG, status))
 		return_0;
 	outf(f, "status = %s", buffer);
 
-	if (!print_flags(status, type, buffer, sizeof(buffer)))
+	if (!print_flags(buffer, sizeof(buffer), type, COMPATIBLE_FLAG, status))
 		return_0;
 	outf(f, "flags = %s", buffer);
 
diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 41f3608..4e49963 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -101,9 +101,9 @@ static const struct flag _lv_flags[] = {
 	{0, NULL, 0}
 };
 
-static const struct flag *_get_flags(int type)
+static const struct flag *_get_flags(enum pv_vg_lv_e type)
 {
-	switch (type & ~STATUS_FLAG) {
+	switch (type) {
 	case VG_FLAGS:
 		return _vg_flags;
 
@@ -123,7 +123,7 @@ static const struct flag *_get_flags(int type)
  * using one of the tables defined at the top of
  * the file.
  */
-int print_flags(uint64_t status, int type, char *buffer, size_t size)
+int print_flags(char *buffer, size_t size, enum pv_vg_lv_e type, int mask, uint64_t status)
 {
 	int f, first = 1;
 	const struct flag *flags;
@@ -167,9 +167,9 @@ int print_flags(uint64_t status, int type, char *buffer, size_t size)
 	return 1;
 }
 
-int read_flags(uint64_t *status, int type, const struct dm_config_value *cv)
+int read_flags(uint64_t *status, enum pv_vg_lv_e type, int mask, const struct dm_config_value *cv)
 {
-	int f;
+	unsigned f;
 	uint64_t s = UINT64_C(0);
 	const struct flag *flags;
 
@@ -186,7 +186,8 @@ int read_flags(uint64_t *status, int type, const struct dm_config_value *cv)
 		}
 
 		for (f = 0; flags[f].description; f++)
-			if (!strcmp(flags[f].description, cv->v.str)) {
+			if ((flags[f].kind & mask) &&
+			    !strcmp(flags[f].description, cv->v.str)) {
 				s |= flags[f].mask;
 				break;
 			}
@@ -200,7 +201,7 @@ int read_flags(uint64_t *status, int type, const struct dm_config_value *cv)
 			 * by this case.
 			 */
 			s |= PARTIAL_VG;
-		} else if (!flags[f].description && (type & STATUS_FLAG)) {
+		} else if (!flags[f].description && (mask & STATUS_FLAG)) {
 			log_error("Unknown status flag '%s'.", cv->v.str);
 			return 0;
 		}
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index c081c51..ddad50f 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -35,14 +35,15 @@
  * VGs, PVs and LVs all have status bitsets, we gather together
  * common code for reading and writing them.
  */
-enum {
-	COMPATIBLE_FLAG = 0x0,
+enum pv_vg_lv_e {
+	PV_FLAGS = 1,
 	VG_FLAGS,
-	PV_FLAGS,
 	LV_FLAGS,
-	STATUS_FLAG = 0x8,
 };
 
+#define COMPATIBLE_FLAG	0x01
+#define STATUS_FLAG	0x02
+
 struct text_vg_version_ops {
 	int (*check_version) (const struct dm_config_tree * cf);
 	struct volume_group *(*read_vg) (struct format_instance * fid,
@@ -58,8 +59,8 @@ struct text_vg_version_ops {
 
 struct text_vg_version_ops *text_vg_vsn1_init(void);
 
-int print_flags(uint64_t status, int type, char *buffer, size_t size);
-int read_flags(uint64_t *status, int type, const struct dm_config_value *cv);
+int print_flags(char *buffer, size_t size, enum pv_vg_lv_e type, int mask, uint64_t status);
+int read_flags(uint64_t *status, enum pv_vg_lv_e type, int mask, const struct dm_config_value *cv);
 
 int text_vg_export_file(struct volume_group *vg, const char *desc, FILE *fp);
 size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf);
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index e545008..6acfe1d 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -140,13 +140,13 @@ static int _read_flag_config(const struct dm_config_node *n, uint64_t *status, i
 		return 0;
 	}
 
-	if (!(read_flags(status, type | STATUS_FLAG, cv))) {
+	if (!(read_flags(status, type, STATUS_FLAG, cv))) {
 		log_error("Could not read status flags.");
 		return 0;
 	}
 
 	if (dm_config_get_list(n, "flags", &cv)) {
-		if (!(read_flags(status, type, cv))) {
+		if (!(read_flags(status, type, COMPATIBLE_FLAG, cv))) {
 			log_error("Could not read flags.");
 			return 0;
 		}


