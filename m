From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:50 +0000 (GMT)
Subject: main - archiving: refactor code to allocate less memory
Message-ID: <20211006134750.F0BFA385AC30@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ea426e65628218569ede461312d80ba5d1c50fb
Commit:        5ea426e65628218569ede461312d80ba5d1c50fb
Parent:        98c57f7ce44788f22499f10f8d6c3f320869aa16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 16:19:53 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:42:53 2021 +0200

archiving: refactor code to allocate less memory

Do not store full path with each archived name reduces memory usage if
the directory has thousands of entries and just add 'dir' path when
needed.

Also emit info print message to a user if the total size of archived
files for a VG is more then 128MiB or 8192 files.

TODO: Consider wheather adding a new 'lvm.conf  archive{option}' to support
trimming these wild archive sizes can make situation better.
We already support retain_min && retain_days  - but if user is
generating too many and too large archives with minutes - maybe archiving
should be disabled by a user - as it's not producing anything largely usable
and just slows-down command ??
If we add 'retain_max & retain_max_size' the condition will go against
each other and we need to chose priorities.

mm
---
 WHATS_NEW                 |   1 +
 lib/format_text/archive.c | 104 ++++++++++++++++++++++++++++------------------
 2 files changed, 64 insertions(+), 41 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0cae2642e..d87cb7e37 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Print info message with too many or too large archived files.
   Reduce metadata readings during scanning phase.
   Optimize computation of crc32 check sum with multiple PVs.
   Enhance recover path on cache creation failure.
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 103b0608d..740129df0 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -49,7 +49,7 @@
 struct archive_file {
 	struct dm_list list;
 
-	const char *path;
+	const char *name;
 	uint32_t index;
 };
 
@@ -105,18 +105,6 @@ static void _insert_archive_file(struct dm_list *head, struct archive_file *b)
 	dm_list_add_h(&bf->list, &b->list);
 }
 
-static char *_join_file_to_dir(struct dm_pool *mem, const char *dir, const char *name)
-{
-	if (!dm_pool_begin_object(mem, 32) ||
-	    !dm_pool_grow_object(mem, dir, strlen(dir)) ||
-	    !dm_pool_grow_object(mem, "/", 1) ||
-	    !dm_pool_grow_object(mem, name, strlen(name)) ||
-	    !dm_pool_grow_object(mem, "\0", 1))
-		return_NULL;
-
-	return dm_pool_end_object(mem);
-}
-
 /*
  * Returns a list of archive_files.
  */
@@ -125,7 +113,7 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 {
 	int i, count;
 	uint32_t ix;
-	char vgname_found[64], *path;
+	char vgname_found[64], *name;
 	struct dirent **dirent = NULL;
 	struct archive_file *af;
 	struct dm_list *results;
@@ -159,7 +147,7 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 		if (strcmp(vgname, vgname_found))
 			continue;
 
-		if (!(path = _join_file_to_dir(mem, dir, dirent[i]->d_name)))
+		if (!(name = dm_pool_strdup(mem, dirent[i]->d_name)))
 			goto_out;
 
 		/*
@@ -172,7 +160,7 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 		}
 
 		af->index = ix;
-		af->path = path;
+		af->name = name;
 
 		/*
 		 * Insert it to the correct part of the list.
@@ -188,12 +176,15 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 	return results;
 }
 
-static void _remove_expired(struct dm_list *archives, uint32_t archives_size,
+static void _remove_expired(const char *dir, const char *vgname,
+			    struct dm_list *archives, uint32_t archives_size,
 			    uint32_t retain_days, uint32_t min_archive)
 {
 	struct archive_file *bf;
 	struct stat sb;
 	time_t retain_time;
+	uint64_t sum = 0;
+	char path[PATH_MAX];
 
 	/* Make sure there are enough archives to even bother looking for
 	 * expired ones... */
@@ -205,23 +196,32 @@ static void _remove_expired(struct dm_list *archives, uint32_t archives_size,
 
 	/* Assume list is ordered newest first (by index) */
 	dm_list_iterate_back_items(bf, archives) {
+		if (dm_snprintf(path, sizeof(path), "%s/%s", dir, bf->name) < 0)
+			continue;
+
 		/* Get the mtime of the file and unlink if too old */
-		if (stat(bf->path, &sb)) {
-			log_sys_error("stat", bf->path);
+		if (stat(path, &sb)) {
+			log_sys_debug("stat", path);
 			continue;
 		}
 
+		sum += sb.st_size;
 		if (sb.st_mtime > retain_time)
-			return;
+			continue;
 
-		log_very_verbose("Expiring archive %s", bf->path);
-		if (unlink(bf->path))
-			log_sys_error("unlink", bf->path);
+		log_very_verbose("Expiring archive %s", path);
+		if (unlink(path))
+			log_sys_debug("unlink", path);
 
 		/* Don't delete any more if we've reached the minimum */
 		if (--archives_size <= min_archive)
-			return;
+			break;
 	}
+
+	sum /= 1024 * 1024;
+	if (sum > 128 || archives_size > 8192)
+		log_print_unless_silent("Consider prunning %s VG archive with more then %u MiB in %u files (check archiving is needed in lvm.conf).",
+					vgname, (unsigned)sum, archives_size);
 }
 
 int archive_vg(struct volume_group *vg,
@@ -292,25 +292,30 @@ int archive_vg(struct volume_group *vg,
 	if (!renamed)
 		log_error("Archive rename failed for %s", temp_file);
 
-	_remove_expired(archives, dm_list_size(archives) + renamed, retain_days,
+	_remove_expired(dir, vg->name, archives, dm_list_size(archives) + renamed, retain_days,
 			min_archive);
 
 	return 1;
 }
 
-static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
+static void _display_archive(struct cmd_context *cmd, const char *dir, struct archive_file *af)
 {
 	struct volume_group *vg = NULL;
 	struct format_instance *tf;
 	struct format_instance_ctx fic;
-	struct text_context tc = {.path_live = af->path,
-				  .path_edit = NULL,
-				  .desc = NULL};
+	struct text_context tc = { NULL };
+	char path[PATH_MAX];
 	time_t when;
 	char *desc;
 
+	if (dm_snprintf(path, sizeof(path), "%s/%s", dir, af->name) < 0) {
+		log_debug("Created path %s/%s is too long.", dir, af->name);
+		return;
+	}
+
 	log_print(" ");
-	log_print("File:\t\t%s", af->path);
+	log_print("File:\t\t%s/%s", path, af->name);
+	tc.path_live = path;
 
 	fic.type = FMT_INSTANCE_PRIVATE_MDAS;
 	fic.context.private = &tc;
@@ -324,7 +329,7 @@ static void _display_archive(struct cmd_context *cmd, struct archive_file *af)
 	 * retrieve the archive time and description.
 	 */
 	/* FIXME Use variation on _vg_read */
-	if (!(vg = text_read_metadata_file(tf, af->path, &when, &desc))) {
+	if (!(vg = text_read_metadata_file(tf, path, &when, &desc))) {
 		log_error("Unable to read archive file.");
 		tf->fmt->ops->destroy_instance(tf);
 		return;
@@ -349,7 +354,7 @@ int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname)
 		log_print("No archives found in %s.", dir);
 
 	dm_list_iterate_back_items(af, archives)
-		_display_archive(cmd, af);
+		_display_archive(cmd, dir, af);
 
 	dm_pool_free(cmd->mem, archives);
 
@@ -358,29 +363,46 @@ int archive_list(struct cmd_context *cmd, const char *dir, const char *vgname)
 
 int archive_list_file(struct cmd_context *cmd, const char *file)
 {
-	struct archive_file af;
+	struct archive_file af = { 0 };
+	char path[PATH_MAX];
+	size_t len;
 
-	af.path = file;
+	if (!path_exists(file)) {
+		log_error("Archive file %s not found.", file);
+		return 0;
+	}
 
-	if (!path_exists(af.path)) {
-		log_error("Archive file %s not found.", af.path);
+	if (!(af.name = strrchr(file, '/'))) {
+		log_error("No '/' in file path %s found.", file);
 		return 0;
 	}
 
-	_display_archive(cmd, &af);
+	len = (size_t)(af.name - file);
+
+	if (len >= sizeof(path)) {
+		log_error(INTERNAL_ERROR "Passed file path name %s is too long.", file);
+		return 0;
+	}
+
+	memcpy(path, file, len);
+	path[len] = 0;
+	af.name++;  /* jump over '/' */
+
+	_display_archive(cmd, path, &af);
 
 	return 1;
 }
 
 int backup_list(struct cmd_context *cmd, const char *dir, const char *vgname)
 {
-	struct archive_file af;
+	struct archive_file af = { .name = vgname };
+	char path[PATH_MAX];
 
-	if (!(af.path = _join_file_to_dir(cmd->mem, dir, vgname)))
+	if (dm_snprintf(path, sizeof(path), "%s/%s", dir, vgname) < 0)
 		return_0;
 
-	if (path_exists(af.path))
-		_display_archive(cmd, &af);
+	if (path_exists(path))
+		_display_archive(cmd, dir, &af);
 
 	return 1;
 }


