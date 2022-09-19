From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:33 +0000 (GMT)
Subject: main - lvmdbusd: Remove PID from log messages
Message-ID: <20220919155833.1E7EF385828F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=664a06650db5acca2ac9a285e6ebddbde6157300
Commit:        664a06650db5acca2ac9a285e6ebddbde6157300
Parent:        b6dc96d8ef03e7af6624ab88a94654ffa94c50ba
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 21:25:36 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Remove PID from log messages

Previously the daemon would output PID:TID.  If it's running under systemd
it skips outputting PID as systemd already does this.
---
 daemons/lvmdbusd/cfg.py   |  2 ++
 daemons/lvmdbusd/main.py  | 17 +++++++++++++++++
 daemons/lvmdbusd/utils.py |  8 ++++++--
 3 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 5b342bc20..142cfabc7 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -113,3 +113,5 @@ def exit_daemon():
 
 # Debug data for lvm
 lvmdebug = None
+
+systemd = False
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index ab66efcc9..ac309aa69 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -129,6 +129,20 @@ def process_args():
 	return args
 
 
+def running_under_systemd():
+	""""
+	Checks to see if we are running under systemd, by checking damon fd 0, 1
+	systemd sets stdin to /dev/null and 1 & 2 are a socket
+	"""
+	base = "/proc/self/fd"
+	stdout = os.readlink("%s/0" % base)
+	if stdout == "/dev/null":
+		stdout = os.readlink("%s/1" % base)
+		if "socket" in stdout:
+			return True
+	return False
+
+
 def main():
 	start = time.time()
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
@@ -142,6 +156,9 @@ def main():
 	# only used for 'fullreport' at this time.
 	cfg.lvmdebug = utils.LvmDebugData()
 
+	# Indicator if we are running under systemd
+	cfg.systemd = running_under_systemd()
+
 	# Add simple command line handling
 	cfg.args = process_args()
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index ec40236a5..3443bdad7 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -308,13 +308,17 @@ class DebugMessages(object):
 def _format_log_entry(msg):
 	tid = ctypes.CDLL('libc.so.6').syscall(186)
 
-	if STDOUT_TTY:
+	if not cfg.systemd and STDOUT_TTY:
 		msg = "%s: %d:%d - %s" % \
 			(datetime.datetime.now().strftime("%b %d %H:%M:%S.%f"),
 			os.getpid(), tid, msg)
 
 	else:
-		msg = "%d:%d - %s" % (os.getpid(), tid, msg)
+		if cfg.systemd:
+			# Systemd already puts the daemon pid in the log, we'll just add the tid
+			msg = "[%d]: %s" % (tid, msg)
+		else:
+			msg = "[%d:%d]: %s" % (os.getpid(), tid, msg)
 	return msg
 
 

