From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 18 Feb 2016 01:15:13 +0000 (UTC)
Subject: master - lvmdbusd: Rename module to lvmdbusd
Message-ID: <20160218011513.99A4560BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6af2ce624481ffe0c7389341d5b4774bf3e7ccff
Commit:        6af2ce624481ffe0c7389341d5b4774bf3e7ccff
Parent:        887e96ded7c46428af44ee324a6bd586112d6474
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Feb 18 01:14:56 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 18 01:14:56 2016 +0000

lvmdbusd: Rename module to lvmdbusd

---
 daemons/lvmdbusd/Makefile.in |    4 +-
 daemons/lvmdbusd/__init__.py |    2 +-
 daemons/lvmdbusd/lvmdbus.py  |  140 ------------------------------------------
 daemons/lvmdbusd/lvmdbusd    |    4 +-
 daemons/lvmdbusd/lvmdbusd.py |  140 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 145 insertions(+), 145 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 6d18564..4b6c71c 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -15,7 +15,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-lvmdbusdir = $(python3dir)/lvmdbus
+lvmdbusdir = $(python3dir)/lvmdbusd
 
 LVMDBUS_SRCDIR_FILES = \
 	automatedproperties.py \
@@ -27,7 +27,7 @@ LVMDBUS_SRCDIR_FILES = \
 	job.py \
 	loader.py \
 	lvmdb.py \
-	lvmdbus.py \
+	lvmdbusd.py \
 	lvm_shell_proxy.py \
 	lv.py \
 	manager.py \
diff --git a/daemons/lvmdbusd/__init__.py b/daemons/lvmdbusd/__init__.py
index b733884..db14fe9 100644
--- a/daemons/lvmdbusd/__init__.py
+++ b/daemons/lvmdbusd/__init__.py
@@ -7,4 +7,4 @@
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
-from .lvmdbus import main
+from .lvmdbusd import main
diff --git a/daemons/lvmdbusd/lvmdbus.py b/daemons/lvmdbusd/lvmdbus.py
deleted file mode 100644
index 43545b2..0000000
--- a/daemons/lvmdbusd/lvmdbus.py
+++ /dev/null
@@ -1,140 +0,0 @@
-# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program. If not, see <http://www.gnu.org/licenses/>.
-
-from . import cfg
-from . import objectmanager
-from . import utils
-from .cfg import BASE_INTERFACE, BASE_OBJ_PATH, MANAGER_OBJ_PATH
-import threading
-from . import cmdhandler
-import time
-import signal
-import dbus
-from . import lvmdb
-# noinspection PyUnresolvedReferences
-from gi.repository import GObject
-from .fetch import load
-from .manager import Manager
-from .background import background_reaper
-import traceback
-import queue
-import sys
-from . import udevwatch
-from .utils import log_debug
-import argparse
-
-
-class Lvm(objectmanager.ObjectManager):
-	def __init__(self, object_path):
-		super(Lvm, self).__init__(object_path, BASE_INTERFACE)
-
-
-def process_request():
-	while cfg.run.value != 0:
-		try:
-			req = cfg.worker_q.get(True, 5)
-
-			start = cfg.db.num_refreshes
-
-			log_debug(
-				"Running method: %s with args %s" %
-				(str(req.method), str(req.arguments)))
-			req.run_cmd()
-
-			end = cfg.db.num_refreshes
-
-			if end - start > 1:
-				log_debug(
-					"Inspect method %s for too many refreshes" %
-					(str(req.method)))
-			log_debug("Complete ")
-		except queue.Empty:
-			pass
-		except Exception:
-			traceback.print_exc(file=sys.stdout)
-			pass
-
-
-def main():
-	# Add simple command line handling
-	parser = argparse.ArgumentParser()
-	parser.add_argument("--udev", action='store_true',
-						help="Use udev for updating state", default=False,
-						dest='use_udev')
-	parser.add_argument("--debug", action='store_true',
-						help="Dump debug messages", default=False,
-						dest='debug')
-
-	args = parser.parse_args()
-
-	cfg.DEBUG = args.debug
-
-	# List of threads that we start up
-	thread_list = []
-
-	start = time.time()
-
-	# Install signal handlers
-	for s in [signal.SIGHUP, signal.SIGINT]:
-		try:
-			signal.signal(s, utils.handler)
-		except RuntimeError:
-			pass
-
-	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
-	GObject.threads_init()
-	dbus.mainloop.glib.threads_init()
-	cfg.bus = dbus.SystemBus()
-	# The base name variable needs to exist for things to work.
-	# noinspection PyUnusedLocal
-	base_name = dbus.service.BusName(BASE_INTERFACE, cfg.bus)
-	cfg.om = Lvm(BASE_OBJ_PATH)
-	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
-
-	cfg.load = load
-
-	cfg.db = lvmdb.DataStore()
-
-	# Start up thread to monitor pv moves
-	thread_list.append(
-		threading.Thread(target=background_reaper, name="pv_move_reaper"))
-
-	# Using a thread to process requests.
-	thread_list.append(threading.Thread(target=process_request))
-
-	cfg.load(refresh=False, emit_signal=False)
-	cfg.loop = GObject.MainLoop()
-
-	for process in thread_list:
-		process.damon = True
-		process.start()
-
-	end = time.time()
-	log_debug(
-		'Service ready! total time= %.2f, lvm time= %.2f count= %d' %
-		(end - start, cmdhandler.total_time, cmdhandler.total_count),
-		'bg_black', 'fg_light_green')
-
-	# Add udev watching
-	if args.use_udev:
-		log_debug('Utilizing udev to trigger updates')
-		udevwatch.add()
-
-	try:
-		if cfg.run.value != 0:
-			cfg.loop.run()
-
-			if args.use_udev:
-				udevwatch.remove()
-
-			for process in thread_list:
-				process.join()
-	except KeyboardInterrupt:
-		utils.handler(signal.SIGINT, None)
-	return 0
diff --git a/daemons/lvmdbusd/lvmdbusd b/daemons/lvmdbusd/lvmdbusd
index 058ddf0..7ea243b 100755
--- a/daemons/lvmdbusd/lvmdbusd
+++ b/daemons/lvmdbusd/lvmdbusd
@@ -10,7 +10,7 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 import sys
-import lvmdbus
+import lvmdbusd
 
 if __name__ == '__main__':
-	sys.exit(lvmdbus.main())
+	sys.exit(lvmdbusd.main())
diff --git a/daemons/lvmdbusd/lvmdbusd.py b/daemons/lvmdbusd/lvmdbusd.py
new file mode 100644
index 0000000..43545b2
--- /dev/null
+++ b/daemons/lvmdbusd/lvmdbusd.py
@@ -0,0 +1,140 @@
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+from . import cfg
+from . import objectmanager
+from . import utils
+from .cfg import BASE_INTERFACE, BASE_OBJ_PATH, MANAGER_OBJ_PATH
+import threading
+from . import cmdhandler
+import time
+import signal
+import dbus
+from . import lvmdb
+# noinspection PyUnresolvedReferences
+from gi.repository import GObject
+from .fetch import load
+from .manager import Manager
+from .background import background_reaper
+import traceback
+import queue
+import sys
+from . import udevwatch
+from .utils import log_debug
+import argparse
+
+
+class Lvm(objectmanager.ObjectManager):
+	def __init__(self, object_path):
+		super(Lvm, self).__init__(object_path, BASE_INTERFACE)
+
+
+def process_request():
+	while cfg.run.value != 0:
+		try:
+			req = cfg.worker_q.get(True, 5)
+
+			start = cfg.db.num_refreshes
+
+			log_debug(
+				"Running method: %s with args %s" %
+				(str(req.method), str(req.arguments)))
+			req.run_cmd()
+
+			end = cfg.db.num_refreshes
+
+			if end - start > 1:
+				log_debug(
+					"Inspect method %s for too many refreshes" %
+					(str(req.method)))
+			log_debug("Complete ")
+		except queue.Empty:
+			pass
+		except Exception:
+			traceback.print_exc(file=sys.stdout)
+			pass
+
+
+def main():
+	# Add simple command line handling
+	parser = argparse.ArgumentParser()
+	parser.add_argument("--udev", action='store_true',
+						help="Use udev for updating state", default=False,
+						dest='use_udev')
+	parser.add_argument("--debug", action='store_true',
+						help="Dump debug messages", default=False,
+						dest='debug')
+
+	args = parser.parse_args()
+
+	cfg.DEBUG = args.debug
+
+	# List of threads that we start up
+	thread_list = []
+
+	start = time.time()
+
+	# Install signal handlers
+	for s in [signal.SIGHUP, signal.SIGINT]:
+		try:
+			signal.signal(s, utils.handler)
+		except RuntimeError:
+			pass
+
+	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
+	GObject.threads_init()
+	dbus.mainloop.glib.threads_init()
+	cfg.bus = dbus.SystemBus()
+	# The base name variable needs to exist for things to work.
+	# noinspection PyUnusedLocal
+	base_name = dbus.service.BusName(BASE_INTERFACE, cfg.bus)
+	cfg.om = Lvm(BASE_OBJ_PATH)
+	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
+
+	cfg.load = load
+
+	cfg.db = lvmdb.DataStore()
+
+	# Start up thread to monitor pv moves
+	thread_list.append(
+		threading.Thread(target=background_reaper, name="pv_move_reaper"))
+
+	# Using a thread to process requests.
+	thread_list.append(threading.Thread(target=process_request))
+
+	cfg.load(refresh=False, emit_signal=False)
+	cfg.loop = GObject.MainLoop()
+
+	for process in thread_list:
+		process.damon = True
+		process.start()
+
+	end = time.time()
+	log_debug(
+		'Service ready! total time= %.2f, lvm time= %.2f count= %d' %
+		(end - start, cmdhandler.total_time, cmdhandler.total_count),
+		'bg_black', 'fg_light_green')
+
+	# Add udev watching
+	if args.use_udev:
+		log_debug('Utilizing udev to trigger updates')
+		udevwatch.add()
+
+	try:
+		if cfg.run.value != 0:
+			cfg.loop.run()
+
+			if args.use_udev:
+				udevwatch.remove()
+
+			for process in thread_list:
+				process.join()
+	except KeyboardInterrupt:
+		utils.handler(signal.SIGINT, None)
+	return 0


