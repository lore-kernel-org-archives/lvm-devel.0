From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 7 Apr 2008 13:53:27 -0000
Subject: LVM2 ./WHATS_NEW lib/log/log.c
Message-ID: <20080407135327.16949.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2008-04-07 13:53:27

Modified files:
	.              : WHATS_NEW 
	lib/log        : log.c 

Log message:
	Fix output if overriding command_names on cmdline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.826&r2=1.827
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2008/04/07 10:23:46	1.826
+++ LVM2/WHATS_NEW	2008/04/07 13:53:26	1.827
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix output if overriding command_names on cmdline.
   Add detection of clustered mirror log capability.
   Add check to vg_commit() ensuring VG lock held before writing new VG metadata.
   Add validation of LV name to pvmove -n.
--- LVM2/lib/log/log.c	2008/01/30 13:59:59	1.42
+++ LVM2/lib/log/log.c	2008/04/07 13:53:26	1.43
@@ -215,12 +215,18 @@
 
 void set_cmd_name(const char *cmd)
 {
-	if (!_log_cmd_name)
-		return;
 	strncpy(_cmd_name, cmd, sizeof(_cmd_name));
 	_cmd_name[sizeof(_cmd_name) - 1] = '\0';
 }
 
+static const char *_command_name()
+{
+	if (!_log_cmd_name)
+		return "";
+
+	return _cmd_name;
+}
+
 void init_msg_prefix(const char *prefix)
 {
 	strncpy(_msg_prefix, prefix, sizeof(_msg_prefix));
@@ -352,7 +358,7 @@
 			    _verbose_level <= _LOG_DEBUG)
 				break;
 			if (_verbose_level >= _LOG_DEBUG) {
-				fprintf(stderr, "%s%s%s", locn, _cmd_name,
+				fprintf(stderr, "%s%s%s", locn, _command_name(),
 					_msg_prefix);
 				if (_indent)
 					fprintf(stderr, "      ");
@@ -363,7 +369,7 @@
 
 		case _LOG_INFO:
 			if (_verbose_level >= _LOG_INFO) {
-				fprintf(stderr, "%s%s%s", locn, _cmd_name,
+				fprintf(stderr, "%s%s%s", locn, _command_name(),
 					_msg_prefix);
 				if (_indent)
 					fprintf(stderr, "    ");
@@ -373,7 +379,7 @@
 			break;
 		case _LOG_NOTICE:
 			if (_verbose_level >= _LOG_NOTICE) {
-				fprintf(stderr, "%s%s%s", locn, _cmd_name,
+				fprintf(stderr, "%s%s%s", locn, _command_name(),
 					_msg_prefix);
 				if (_indent)
 					fprintf(stderr, "  ");
@@ -383,14 +389,15 @@
 			break;
 		case _LOG_WARN:
 			if (_verbose_level >= _LOG_WARN) {
-				fprintf(use_stderr ? stderr : stdout, "%s%s", _cmd_name, _msg_prefix);
+				fprintf(use_stderr ? stderr : stdout, "%s%s",
+					_command_name(), _msg_prefix);
 				vfprintf(use_stderr ? stderr : stdout, trformat, ap);
 				fputc('\n', use_stderr ? stderr : stdout);
 			}
 			break;
 		case _LOG_ERR:
 			if (_verbose_level >= _LOG_ERR) {
-				fprintf(stderr, "%s%s%s", locn, _cmd_name,
+				fprintf(stderr, "%s%s%s", locn, _command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
 				fputc('\n', stderr);
@@ -399,7 +406,7 @@
 		case _LOG_FATAL:
 		default:
 			if (_verbose_level >= _LOG_FATAL) {
-				fprintf(stderr, "%s%s%s", locn, _cmd_name,
+				fprintf(stderr, "%s%s%s", locn, _command_name(),
 					_msg_prefix);
 				vfprintf(stderr, trformat, ap);
 				fputc('\n', stderr);
@@ -413,7 +420,7 @@
 		return;
 
 	if (_log_to_file && (_log_while_suspended || !memlock())) {
-		fprintf(_log_file, "%s:%d %s%s", file, line, _cmd_name,
+		fprintf(_log_file, "%s:%d %s%s", file, line, _command_name(),
 			_msg_prefix);
 
 		va_start(ap, format);
@@ -436,7 +443,7 @@
 		memset(&buf, ' ', sizeof(buf));
 		bufused = 0;
 		if ((n = dm_snprintf(buf, sizeof(buf) - bufused - 1,
-				      "%s:%d %s%s", file, line, _cmd_name,
+				      "%s:%d %s%s", file, line, _command_name(),
 				      _msg_prefix)) == -1)
 			goto done;
 


