From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 Jul 2016 10:47:37 +0000 (UTC)
Subject: master - tests: add LVM_LOG_FILE_MAX_LINES
Message-ID: <20160711104737.C111F60D2B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34c55d98eefd88f85476c0f62f0649c706bde6f0
Commit:        34c55d98eefd88f85476c0f62f0649c706bde6f0
Parent:        309bdfa22417cf77e7be2349c414295d83d47fbc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 12:43:28 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 12:43:28 2016 +0200

tests: add LVM_LOG_FILE_MAX_LINES

When logging to epoch files we would like to prevent creating too large
log files otherwise a spining command could fulfill available space
very easily and quickly.

Limit for to 100000 per command.
---
 WHATS_NEW            |    1 +
 lib/log/log.c        |   13 +++++++++++++
 man/lvm.8.in         |    5 +++++
 test/lib/inittest.sh |    1 +
 4 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5be0449..5653b13 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.161 - 
 ================================
+  New LVM_LOG_FILE_MAX_LINES env var to limit max size of created logs.
 
 Version 2.02.160 - 6th July 2016
 ================================
diff --git a/lib/log/log.c b/lib/log/log.c
index 30d71ef..434b8d0 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -31,6 +31,8 @@ static struct dm_str_list _log_dev_alias;
 
 static int _syslog = 0;
 static int _log_to_file = 0;
+static uint64_t _log_file_max_lines = 0;
+static uint64_t _log_file_lines = 0;
 static int _log_direct = 0;
 static int _log_while_suspended = 0;
 static int _indent = 1;
@@ -111,6 +113,14 @@ void init_log_file(const char *log_file, int append)
 
 		if (st && fclose(st))
 			log_sys_debug("fclose", statfile);
+
+		if ((env = getenv("LVM_LOG_FILE_MAX_LINES"))) {
+			if (sscanf(env, FMTu64, &_log_file_max_lines) != 1) {
+				log_warn("WARNING: Ingnoring incorrect LVM_LOG_MAX_LINES envvar \"%s\".", env);
+				_log_file_max_lines = 0;
+			}
+			_log_file_lines = 0;
+		}
 	}
 
 no_epoch:
@@ -487,6 +497,9 @@ static void _vprint_log(int level, const char *file, int line, int dm_errno_or_c
 
 		fputc('\n', _log_file);
 		fflush(_log_file);
+
+		if (_log_file_max_lines && ++_log_file_lines >= _log_file_max_lines)
+			fatal_internal_error = 1;
 	}
 
 	if (_syslog && (_log_while_suspended || !critical_section())) {
diff --git a/man/lvm.8.in b/man/lvm.8.in
index 729518b..82d0558 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -778,6 +778,11 @@ followed by the process ID and a startup timestamp using
 this format string "_%s_%d_%llu".  When set, each process logs to a
 separate file.
 .TP
+.B LVM_LOG_FILE_MAX_LINES
+A max number of lines to be printed to log file before
+the application aborts. Useful for testing to prevent creation
+of too big log files from spinning command.
+.TP
 .B LVM_EXPECTED_EXIT_STATUS
 The status anticipated when the process exits.  Use ">N" to match any
 status greater than N.  If the actual exit status matches and a log
diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index a453ee6..dcc1304 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -58,6 +58,7 @@ RUNNING_DMEVENTD=$(pgrep dmeventd || true)
 
 export TESTOLDPWD TESTDIR COMMON_PREFIX PREFIX RUNNING_DMEVENTD
 export LVM_LOG_FILE_EPOCH=DEBUG
+export LVM_LOG_FILE_MAX_LINES=100000
 export LVM_EXPECTED_EXIT_STATUS=1
 
 test -n "$BASH" && trap 'set +vx; STACKTRACE; set -vx' ERR


