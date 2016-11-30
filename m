From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:35 +0000 (UTC)
Subject: master - lvmdbusd: Add --blackboxsize command line argument
Message-ID: <20161130215935.E91A46096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3bc69cb23c29e8e016282508514ce191c756b89c
Commit:        3bc69cb23c29e8e016282508514ce191c756b89c
Parent:        b0757ac96e5c0f50e8d088200eb1ad62e535fcb6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 18:01:56 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbusd: Add --blackboxsize command line argument

Allows the user to override the number of commands that get dumped
to the log when we encounter a lvm error.  Also useful during
development when you don't want to see the blackbox output.
---
 daemons/lvmdbusd/cmdhandler.py |   13 +++++++------
 daemons/lvmdbusd/main.py       |   16 ++++++++++++++--
 2 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index f221f93..f1591aa 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -55,18 +55,19 @@ class LvmExecutionMeta(object):
 
 class LvmFlightRecorder(object):
 
-	def __init__(self):
-		self.queue = collections.deque(maxlen=16)
+	def __init__(self, size=16):
+		self.queue = collections.deque(maxlen=size)
 
 	def add(self, lvm_exec_meta):
 		self.queue.append(lvm_exec_meta)
 
 	def dump(self):
 		with cmd_lock:
-			log_error("LVM dbus flight recorder START")
-			for c in self.queue:
-				log_error(str(c))
-			log_error("LVM dbus flight recorder END")
+			if len(self.queue):
+				log_error("LVM dbus flight recorder START")
+				for c in self.queue:
+					log_error(str(c))
+				log_error("LVM dbus flight recorder END")
 
 
 cfg.blackbox = LvmFlightRecorder()
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 4b9f94e..9bf0871 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -29,6 +29,7 @@ from .utils import log_debug, log_error
 import argparse
 import os
 import sys
+from .cmdhandler import LvmFlightRecorder
 
 
 class Lvm(objectmanager.ObjectManager):
@@ -75,6 +76,12 @@ def main():
 		help="Use the lvm shell, not fork & exec lvm",
 		default=False,
 		dest='use_lvm_shell')
+	parser.add_argument(
+		"--blackboxsize",
+		help="Size of the black box flight recorder, 0 to disable",
+		default=10,
+		type=int,
+		dest='bb_size')
 
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
@@ -83,6 +90,11 @@ def main():
 
 	cfg.args = parser.parse_args()
 
+	# We create a flight recorder in cmdhandler too, but we replace it here
+	# as the user may be specifying a different size.  The default one in
+	# cmdhandler is for when we are running other code with a different main.
+	cfg.blackbox = LvmFlightRecorder(cfg.args.bb_size)
+
 	if cfg.args.use_lvm_shell and not cfg.args.use_json:
 		log_error("You cannot specify --lvmshell and --nojson")
 		sys.exit(1)
@@ -118,8 +130,8 @@ def main():
 	# thread that is handling the dbus interface
 	thread_list.append(threading.Thread(target=process_request))
 
-	# Have a single thread handling updating lvm and the dbus model so we don't
-	# have multiple threads doing this as the same time
+	# Have a single thread handling updating lvm and the dbus model so we
+	# don't have multiple threads doing this as the same time
 	updater = StateUpdate()
 	thread_list.append(updater.thread)
 


