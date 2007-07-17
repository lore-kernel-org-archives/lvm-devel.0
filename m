From: Jim Meyering <jim@meyering.net>
Date: Tue, 17 Jul 2007 16:57:05 +0200
Subject: Detect unlikely write failure: persistent device cache, config file
In-Reply-To: <87wsx01r2z.fsf@rho.meyering.net> (Jim Meyering's message of
	"Mon\, 16 Jul 2007 14\:16\:36 +0200")
References: <87wsx01r2z.fsf@rho.meyering.net>
Message-ID: <87hco3ulha.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jim Meyering <jim@meyering.net> wrote:
> Here's the patch I mentioned last week.
> The only real question is where the new (tiny) close_stream function belongs.
> Putting it in config.h is not ideal, but does work, since the two files
> that close written-to streams also include config.h.
>
> Would you like a new .h file as I did for lib/misc/last-component.h?
> This time, it'd be lib/misc/close-stream.h.
>
> Or maybe a pair of files:
>   lib/misc/close-stream.c
>   lib/misc/close-stream.h

There are a few more places where that was needed, and not all new
callers include config.h, so I've moved the close_stream definition
to lib.h.  Here's an updated patch:

Detect write failure more reliably.
 * lib/misc/lib.h (close_stream): New static inline function.
 * lib/config/config.c (write_config_file): Use the new function
 to detect and diagnose unlikely write failure.
 * lib/filters/filter-persistent.c (persistent_filter_dump): Likewise.
 * lib/format_text/archive.c (archive_vg): Likewise.
 * lib/format_text/format-text.c (_vg_write_file): Likewise.
 * lib/log/log.c (fin_log): Likewise.
 * WHATS_NEW: Mention this.

Signed-off-by: Jim Meyering <jim@meyering.net>
---
 WHATS_NEW                       |    1 +
 lib/config/config.c             |    7 +++++--
 lib/filters/filter-persistent.c |    7 +++++--
 lib/format_text/archive.c       |    7 +++++--
 lib/format_text/format-text.c   |    7 +++++--
 lib/log/log.c                   |    9 +++++++--
 lib/misc/lib.h                  |   23 +++++++++++++++++++++++
 7 files changed, 51 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 56f579e..b92450c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Detect write failure more reliably.
   Fix configure libdevmapper.h check when --with-dmdir is used.
   Turn _add_pv_to_vg() into external library function add_pv_to_vg().
   Add pv_by_path() external library function.
diff --git a/lib/config/config.c b/lib/config/config.c
index b5f0038..8f02e13 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -518,8 +518,11 @@ int write_config_file(struct config_tree *cft, const char *file,
 		argv++;
 	}
 
-	if (outline.fp && fclose(outline.fp)) {
-		log_sys_error("fclose", file);
+	if (outline.fp && close_stream(outline.fp) != 0) {
+		if (errno == 0)
+			log_error("%s: write error", file);
+		else
+			log_sys_error("fclose", file);
 		r = 0;
 	}
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 91e7147..58a89ce 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -239,8 +239,11 @@ int persistent_filter_dump(struct dev_filter *f)
 	/* _write_array(pf, fp, "invalid_devices", PF_BAD_DEVICE); */
 
 	fprintf(fp, "}\n");
-	if (fclose(fp)) {
-		log_sys_error("fclose", tmp_file);
+	if (close_stream(fp) != 0) {
+		if (errno == 0)
+			log_error("%s: write error", tmp_file);
+		else
+			log_sys_error("fclose", tmp_file);
 		goto out;
 	}
 
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index c6af857..2cf0809 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -261,8 +261,11 @@ int archive_vg(struct volume_group *vg,
 		return 0;
 	}
 
-	if (fclose(fp)) {
-		log_sys_error("fclose", temp_file);
+	if (close_stream(fp) != 0) {
+		if (errno == 0)
+			log_error("%s: write error", temp_file);
+		else
+			log_sys_error("fclose", temp_file);
 		/* Leave file behind as evidence of failure */
 		return 0;
 	}
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e8bf6f6..5f280ff 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -892,8 +892,11 @@ static int _vg_write_file(struct format_instance *fid, struct volume_group *vg,
 		return 0;
 	}
 
-	if (fclose(fp)) {
-		log_sys_error("fclose", tc->path_edit);
+	if (close_stream(fp) != 0) {
+		if (errno == 0)
+			log_error("%s: write error", tc->path_edit);
+		else
+			log_sys_error("fclose", tc->path_edit);
 		return 0;
 	}
 
diff --git a/lib/log/log.c b/lib/log/log.c
index a67abe6..f3cac82 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -121,8 +121,13 @@ void fin_log(void)
 	}
 
 	if (_log_to_file) {
-		if (fclose(_log_file))
-			fprintf(stderr, "fclose() on log file failed: %s", strerror(errno));
+		if (close_stream(_log_file) != 0) {
+			if (errno == 0)
+			      fprintf(stderr, "log file write failed");
+			else
+			      fprintf(stderr, "fclose() on log file failed: %s",
+				      strerror(errno));
+		}
 		_log_to_file = 0;
 	}
 }
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index c3d5231..3d851cd 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -32,4 +32,27 @@
 
 #include <libdevmapper.h>
 
+/*
+ * Close a stream, with nicer error checking than fclose's.
+ * Derived from gnulib's close-stream.c.
+ *
+ * Close STREAM.  Return 0 if successful, nonzero (setting errno)
+ * otherwise.  Upon failure, set errno to 0 if the error number
+ * cannot be determined.
+ */
+static inline int
+close_stream(FILE *stream)
+{
+	int prev_fail = ferror(stream);
+	int fclose_fail = fclose(stream);
+
+	/* If there was a previous failure, but fclose succeeded,
+	   clear errno, since ferror does not set it, and its value
+	   may be unrelated to the ferror-reported failure.  */
+	if (prev_fail && !fclose_fail)
+		errno = 0;
+
+	return prev_fail || fclose_fail;
+}
+
 #endif
-- 
1.5.3.rc1.27.ga5e40


