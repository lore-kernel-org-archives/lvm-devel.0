From: Jim Meyering <jim@meyering.net>
Date: Mon, 16 Jul 2007 14:16:36 +0200
Subject: Detect unlikely write failure: persistent device cache, config file
Message-ID: <87wsx01r2z.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

Here's the patch I mentioned last week.
The only real question is where the new (tiny) close_stream function belongs.
Putting it in config.h is not ideal, but does work, since the two files
that close written-to streams also include config.h.

Would you like a new .h file as I did for lib/misc/last-component.h?
This time, it'd be lib/misc/close-stream.h.

Or maybe a pair of files:
  lib/misc/close-stream.c
  lib/misc/close-stream.h

Here's the patch with the new static inline function in config.h:

-----------------------------------------------
Detect unlikely write failure: persistent device cache, config file
 * lib/config/config.h (close_stream): New static inline function.
 * lib/filters/filter-persistent.c (persistent_filter_dump): Use the
 new function to detect and diagnose unlikely write failure.
 * lib/config/config.c (write_config_file): Likewise.
 * WHATS_NEW: Mention this.


Signed-off-by: Jim Meyering <jim@meyering.net>
---
 WHATS_NEW                       |    1 +
 lib/config/config.c             |    7 +++++--
 lib/config/config.h             |   21 +++++++++++++++++++++
 lib/filters/filter-persistent.c |    7 +++++--
 4 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 56f579e..8b44142 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.27 - 
 ================================
+  Detect unlikely write failure: persistent device cache, config file
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
 
diff --git a/lib/config/config.h b/lib/config/config.h
index ad27b0f..5658ecc 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -110,4 +110,25 @@ int get_config_str(const struct config_node *cn, const char *path,
 
 unsigned maybe_config_section(const char *str, unsigned len);
 
+/* Close a stream, with nicer error checking than fclose's.
+   Derived from gnulib's close-stream.c.
+
+   Close STREAM.  Return 0 if successful, nonzero (setting errno)
+   otherwise.  Upon failure, set errno to 0 if the error number
+   cannot be determined.  */
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
 
-- 
1.5.3.rc1.27.ga5e40


