From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Jul 2013 13:36:26 +0000 (UTC)
Subject: master - libdm: add DM_ABORT_ON_INTERNAL_ERRORS
Message-ID: <20130731133626.BC6A960319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5d9628475e81b15f3196a69ab4b3288466cd168f
Commit:        5d9628475e81b15f3196a69ab4b3288466cd168f
Parent:        4a722c5c8bcc902043ece29550a5d61ea7fdbef3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 25 14:32:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 31 15:27:34 2013 +0200

libdm: add DM_ABORT_ON_INTERNAL_ERRORS

Support tests with abort when libdm encounters internal
error - i.e. for dmsetup tool.

Code execution will be aborted when
env var DM_ABORT_ON_INTERNAL_ERRORS is set to 1
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    1 +
 libdm/libdm-common.c |   30 +++++++++++++++++-------------
 test/lib/test.sh     |    5 ++++-
 4 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index cd77bc6..ffee9a3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.79 -
 ================================
+  Add DM_ABORT_ON_INTERNAL_ERRORS env var support to abort on internal errors.
 
 Version 1.02.78 - 24th July 2013
 ================================
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 0c415c6..0b03eaf 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -57,6 +57,7 @@ extern "C" {
  * Use dm_log_with_errno_init(NULL) to restore the default log fn.
  * Error messages may have a non-zero errno.
  * Debug messages may have a non-zero class.
+ * Aborts on internal error when env DM_ABORT_ON_INTERNAL_ERRORS is 1
  */
 
 typedef void (*dm_log_with_errno_fn) (int level, const char *file, int line,
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 8d5eca8..de4b747 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -114,22 +114,26 @@ static void _default_log_line(int level,
 	    int line __attribute__((unused)), int dm_errno_or_class, 
 	    const char *f, va_list ap)
 {
-	int use_stderr = level & _LOG_STDERR;
+	static int _abort_on_internal_errors = -1;
+	FILE *out = (level & _LOG_STDERR) ? stderr : stdout;
 
 	level &= ~_LOG_STDERR;
 
-	if (level > _LOG_WARN && !_verbose)
-		return;
+	if (level <= _LOG_WARN || _verbose) {
+		if (level < _LOG_WARN)
+			out = stderr;
+		vfprintf(out, f, ap);
+		fputc('\n', out);
+	}
 
-	if (level < _LOG_WARN)
-		vfprintf(stderr, f, ap);
-	else
-		vfprintf(use_stderr ? stderr : stdout, f, ap);
+	if (_abort_on_internal_errors < 0)
+		/* Set when env DM_ABORT_ON_INTERNAL_ERRORS is 1 */
+		_abort_on_internal_errors =
+			!strcmp(getenv("DM_ABORT_ON_INTERNAL_ERRORS") ? : "0", "1");
 
-	if (level < _LOG_WARN)
-		fprintf(stderr, "\n");
-	else
-		fprintf(use_stderr ? stderr : stdout, "\n");
+	if (_abort_on_internal_errors &&
+	    !strncmp(f, INTERNAL_ERROR, sizeof(INTERNAL_ERROR) - 1))
+		abort();
 }
 
 __attribute__((format(printf, 5, 6)))
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 7e0df73..20da059 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -50,7 +50,10 @@ else
 	mkdir "$DM_DEV_DIR/mapper"
 fi
 
-export DM_DEV_DIR LVM_SYSTEM_DIR
+# abort on the internal dm errors in the tests (allowing test user override)
+DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
+
+export DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
 
 cd "$TESTDIR"
 


