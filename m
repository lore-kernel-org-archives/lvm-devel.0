From: Jim Meyering <jim@meyering.net>
Date: Mon, 06 Aug 2007 21:17:21 +0200
Subject: stack smash?
Message-ID: <871wegcw1q.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the vicinity of today's s/newname/new_name/ change, I spotted
what looks like a potential stack smashing bug, though I confess
I haven't tried to provoke it yet.  It would require an abusively
long name, where the original has length < PATH_MAX, but the new
one's longer final component would make strcpy write beyond the
end of new_name.  Patch below.

Caveat: There may well be code somewhere that ensures ->path_live is so
much shorter than PATH_MAX that this is a non-issue.  But if that's the
case, please let me know and instead, I'll add a comment or some sort
of assertion here to that effect.

Assuming this patch is on the right track (yes, I'll test first),
any preference on where to #define MIN?  Or different spelling?
Obviously, it doesn't belong in this file.

Jim


diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 9085b2d..d1eb85f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -39,6 +39,9 @@
 #define FMT_TEXT_NAME "lvm2"
 #define FMT_TEXT_ALIAS "text"

+#undef MIN
+#define MIN(x,y) ((x) < (y) ? (x) : (y))
+
 static struct mda_header *_raw_read_mda_header(const struct format_type *fmt,
 					       struct device_area *dev_area);

@@ -939,8 +942,6 @@ static int _vg_commit_file(struct format_instance *fid, struct volume_group *vg,
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 	char *slash;
-	char new_name[PATH_MAX];
-	size_t len;

 	if (!_vg_commit_file_backup(fid, vg, mda))
 		return 0;
@@ -952,14 +953,25 @@ static int _vg_commit_file(struct format_instance *fid, struct volume_group *vg,
 		slash = tc->path_live;

 	if (strcmp(slash, vg->name)) {
-		len = slash - tc->path_live;
+		char new_name[PATH_MAX];
+		size_t len = slash - tc->path_live;
+		size_t rem = sizeof new_name - len;
 		strncpy(new_name, tc->path_live, len);
+		if (strlen(vg->name) >= rem) {
+			/* Append "...\0" (or whatever will fit) for diag.  */
+			size_t n_dots = MIN(3, rem-1);
+			memset(new_name + len, '.', n_dots);
+			new_name[len + n_dots] = '\0';
+			errno = ENAMETOOLONG;
+			goto rename_failed;
+		}
 		strcpy(new_name + len, vg->name);
 		log_debug("Renaming %s to %s", tc->path_live, new_name);
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename");
 		else {
 			if (rename(tc->path_live, new_name)) {
+		      rename_failed:
 				log_error("%s: rename to %s failed: %s",
 					  tc->path_live, new_name,
 					  strerror(errno));


