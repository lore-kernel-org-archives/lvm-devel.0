From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:48 +0000 (GMT)
Subject: main - lvmdbusd: Move arg. setup/checking to function
Message-ID: <20220919155748.C90233858C50@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1a4384979cdf889bd63a932d83933079c53490ae
Commit:        1a4384979cdf889bd63a932d83933079c53490ae
Parent:        3eb19c4b7ae0b0b862a9cf92760922e4a524600a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 8 20:44:32 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Move arg. setup/checking to function

---
 daemons/lvmdbusd/main.py  | 37 ++++++++++++++++++++++---------------
 daemons/lvmdbusd/utils.py |  4 ++++
 2 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 50b8e568f..1e883c901 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -25,7 +25,7 @@ from .manager import Manager
 import traceback
 import queue
 from . import udevwatch
-from .utils import log_debug, log_error
+from .utils import log_debug, log_error, log_msg
 import argparse
 import os
 import sys
@@ -81,9 +81,7 @@ def install_signal_handlers():
 		log_error("GLib.unix_signal_[add|add_full] are NOT available!")
 
 
-def main():
-	start = time.time()
-	# Add simple command line handling
+def process_args():
 	parser = argparse.ArgumentParser()
 	parser.add_argument(
 		"--udev", action='store_true',
@@ -110,14 +108,9 @@ def main():
 		type=check_bb_size,
 		dest='bb_size')
 
-	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
-
-	# Ensure that we get consistent output for parsing stdout/stderr
-	os.environ["LC_ALL"] = "C"
-
-	cfg.args = parser.parse_args()
+	args = parser.parse_args()
 
-	if not cfg.args.use_json:
+	if not args.use_json:
 		log_error("Daemon no longer supports lvm without JSON support, exiting!")
 		sys.exit(1)
 	else:
@@ -125,6 +118,24 @@ def main():
 			log_error("Un-supported version of LVM, daemon requires JSON output, exiting!")
 			sys.exit(1)
 
+	# Add udev watching
+	if args.use_udev:
+		# Make sure this msg ends up in the journal, so we know
+		log_msg('Utilizing udev to trigger updates')
+
+	return args
+
+
+def main():
+	start = time.time()
+	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
+
+	# Ensure that we get consistent output for parsing stdout/stderr
+	os.environ["LC_ALL"] = "C"
+
+	# Add simple command line handling
+	cfg.args = process_args()
+
 	cfg.create_request_entry = RequestEntry
 
 	# We create a flight recorder in cmdhandler too, but we replace it here
@@ -178,10 +189,6 @@ def main():
 		thread.damon = True
 		thread.start()
 
-	# Add udev watching
-	if cfg.args.use_udev:
-		log_debug('Utilizing udev to trigger updates')
-
 	# In all cases we are going to monitor for udev until we get an
 	# ExternalEvent.  In the case where we get an external event and the user
 	# didn't specify --udev we will stop monitoring udev
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index cc221fc2d..f5bca1b46 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -313,6 +313,10 @@ def log_error(msg, *attributes):
 	_common_log(msg, *attributes)
 
 
+def log_msg(msg, *attributes):
+	_common_log(msg, *attributes)
+
+
 def dump_threads_stackframe():
 	ident_to_name = {}
 

