From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:29 +0000 (UTC)
Subject: master - lvmdbusd: Use one thread to fetch state updates
Message-ID: <20161117173629.DC73E605B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa444906bbe5eda22aa5823ef2f9e196b0c15602
Commit:        fa444906bbe5eda22aa5823ef2f9e196b0c15602
Parent:        affe2cebf51169bff01fe20d9f4f1298bba9e1f9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 10 12:19:48 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: Use one thread to fetch state updates

In preparation to have more than one thread issuing commands to lvm
at the same time we need to serialize updates to the dbus state and
retrieving the global lvm state.  To achieve this we have one thread
handling this with a thread safe queue taking and coalescing requests.
---
 daemons/lvmdbusd/cfg.py       |    1 +
 daemons/lvmdbusd/fetch.py     |  114 ++++++++++++++++++++++++++++++++++++++++-
 daemons/lvmdbusd/main.py      |   63 +++++-----------------
 daemons/lvmdbusd/manager.py   |    5 +-
 daemons/lvmdbusd/refresh.py   |   45 ----------------
 daemons/lvmdbusd/udevwatch.py |    3 +-
 6 files changed, 131 insertions(+), 100 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index e5bd9e2..0612154 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -78,6 +78,7 @@ hidden_lv = itertools.count()
 
 # Used to prevent circular imports...
 load = None
+event = None
 
 # Global cached state
 db = None
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 7626460..409b19d 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -11,7 +11,10 @@ from .pv import load_pvs
 from .vg import load_vgs
 from .lv import load_lvs
 from . import cfg
-from .utils import MThreadRunner, log_debug
+from .utils import MThreadRunner, log_debug, log_error
+import threading
+import queue
+import traceback
 
 
 def _main_thread_load(refresh=True, emit_signal=True):
@@ -45,3 +48,112 @@ def load(refresh=True, emit_signal=True, cache_refresh=True, log=True,
 		rc = _main_thread_load(refresh, emit_signal)
 
 	return rc
+
+
+# Even though lvm can handle multiple changes concurrently it really doesn't
+# make sense to make a 1-1 fetch of data for each change of lvm because when
+# we fetch the data once all previous changes are reflected.
+class StateUpdate(object):
+
+	class UpdateRequest(object):
+
+		def __init__(self, refresh, emit_signal, cache_refresh, log,
+						need_main_thread):
+			self.is_done = False
+			self.refresh = refresh
+			self.emit_signal = emit_signal
+			self.cache_refresh = cache_refresh
+			self.log = log
+			self.need_main_thread = need_main_thread
+			self.result = None
+			self.cond = threading.Condition(threading.Lock())
+
+		def done(self):
+			with self.cond:
+				if not self.is_done:
+					self.cond.wait()
+			return self.result
+
+		def set_result(self, result):
+			with self.cond:
+				self.result = result
+				self.is_done = True
+				self.cond.notify_all()
+
+	@staticmethod
+	def update_thread(obj):
+		while cfg.run.value != 0:
+			# noinspection PyBroadException
+			try:
+				queued_requests = []
+				refresh = True
+				emit_signal = True
+				cache_refresh = True
+				log = True
+				need_main_thread = True
+
+				with obj.lock:
+					wait = not obj.deferred
+					obj.deferred = False
+
+				if wait:
+					queued_requests.append(obj.queue.get(True, 2))
+
+				# Ok we have one or the deferred queue has some,
+				# check if any others
+				try:
+					while True:
+						queued_requests.append(obj.queue.get(False))
+
+				except queue.Empty:
+					pass
+
+				log_debug("Processing %d updates!" % len(queued_requests))
+
+				# We have what we can, run the update with the needed options
+				for i in queued_requests:
+					if not i.refresh:
+						refresh = False
+					if not i.emit_signal:
+						emit_signal = False
+					if not i.cache_refresh:
+						cache_refresh = False
+					if not i.log:
+						log = False
+					if not i.need_main_thread:
+						need_main_thread = False
+
+				num_changes = load(refresh, emit_signal, cache_refresh, log,
+									need_main_thread)
+				# Update is done, let everyone know!
+				for i in queued_requests:
+					i.set_result(num_changes)
+
+			except queue.Empty:
+				pass
+			except Exception:
+				st = traceback.format_exc()
+				log_error("update_thread exception: \n%s" % st)
+
+	def __init__(self):
+		self.lock = threading.RLock()
+		self.queue = queue.Queue()
+		self.deferred = False
+
+		# Do initial load
+		load(refresh=False, emit_signal=False, need_main_thread=False)
+
+		self.thread = threading.Thread(target=StateUpdate.update_thread,
+										args=(self,))
+
+	def load(self, refresh=True, emit_signal=True, cache_refresh=True,
+					log=True, need_main_thread=True):
+		# Place this request on the queue and wait for it to be completed
+		req = StateUpdate.UpdateRequest(refresh, emit_signal, cache_refresh,
+										log, need_main_thread)
+		self.queue.put(req)
+		return req.done()
+
+	def event(self):
+		with self.lock:
+			self.deferred = True
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 80a576a..6e782d2 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -20,7 +20,7 @@ import dbus.mainloop.glib
 from . import lvmdb
 # noinspection PyUnresolvedReferences
 from gi.repository import GLib
-from .fetch import load
+from .fetch import StateUpdate
 from .manager import Manager
 import traceback
 import queue
@@ -29,7 +29,6 @@ from .utils import log_debug, log_error
 import argparse
 import os
 import sys
-from .refresh import handle_external_event, event_complete
 
 
 class Lvm(objectmanager.ObjectManager):
@@ -37,54 +36,15 @@ class Lvm(objectmanager.ObjectManager):
 		super(Lvm, self).__init__(object_path, BASE_INTERFACE)
 
 
-def _discard_pending_refreshes():
-	# We just handled a refresh, if we have any in the queue they can be
-	# removed because by definition they are older than the refresh we just did.
-	# As we limit the number of refreshes getting into the queue
-	# we should only ever have one to remove.
-	requests = []
-	while not cfg.worker_q.empty():
-		try:
-			r = cfg.worker_q.get(block=False)
-			if r.method != handle_external_event:
-				requests.append(r)
-			else:
-				# Make sure we make this event complete even though it didn't
-				# run, otherwise no other events will get processed
-				event_complete()
-				break
-		except queue.Empty:
-			break
-
-	# Any requests we removed, but did not discard need to be re-queued
-	for r in requests:
-		cfg.worker_q.put(r)
-
-
 def process_request():
 	while cfg.run.value != 0:
 		# noinspection PyBroadException
 		try:
 			req = cfg.worker_q.get(True, 5)
-
-			start = cfg.db.num_refreshes
-
 			log_debug(
 				"Running method: %s with args %s" %
 				(str(req.method), str(req.arguments)))
 			req.run_cmd()
-
-			end = cfg.db.num_refreshes
-
-			num_refreshes = end - start
-
-			if num_refreshes > 0:
-				_discard_pending_refreshes()
-
-				if num_refreshes > 1:
-					log_debug(
-						"Inspect method %s for too many refreshes" %
-						(str(req.method)))
 			log_debug("Method complete ")
 		except queue.Empty:
 			pass
@@ -152,20 +112,25 @@ def main():
 	cfg.om = Lvm(BASE_OBJ_PATH)
 	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
 
-	cfg.load = load
-
 	cfg.db = lvmdb.DataStore(cfg.args.use_json)
 
 	# Using a thread to process requests, we cannot hang the dbus library
 	# thread that is handling the dbus interface
 	thread_list.append(threading.Thread(target=process_request))
 
-	cfg.load(refresh=False, emit_signal=False, need_main_thread=False)
+	# Have a single thread handling updating lvm and the dbus model so we don't
+	# have multiple threads doing this as the same time
+	updater = StateUpdate()
+	thread_list.append(updater.thread)
+
+	cfg.load = updater.load
+	cfg.event = updater.event
+
 	cfg.loop = GLib.MainLoop()
 
-	for process in thread_list:
-		process.damon = True
-		process.start()
+	for thread in thread_list:
+		thread.damon = True
+		thread.start()
 
 	# Add udev watching
 	if cfg.args.use_udev:
@@ -187,8 +152,8 @@ def main():
 			cfg.loop.run()
 			udevwatch.remove()
 
-			for process in thread_list:
-				process.join()
+			for thread in thread_list:
+				thread.join()
 	except KeyboardInterrupt:
 		utils.handler(signal.SIGINT, None)
 	return 0
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index e81ee1f..821c625 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -14,9 +14,7 @@ from .cfg import MANAGER_INTERFACE
 import dbus
 from . import cfg
 from . import cmdhandler
-from .fetch import load_pvs, load_vgs
 from .request import RequestEntry
-from .refresh import event_add
 from . import udevwatch
 
 
@@ -183,7 +181,8 @@ class Manager(AutomatedProperties):
 								"udev monitoring")
 				# We are dependent on external events now to stay current!
 				cfg.ee = True
-		event_add((command,))
+		utils.log_debug("ExternalEvent %s" % command)
+		cfg.event()
 		return dbus.Int32(0)
 
 	@staticmethod
diff --git a/daemons/lvmdbusd/refresh.py b/daemons/lvmdbusd/refresh.py
deleted file mode 100644
index e29afd6..0000000
--- a/daemons/lvmdbusd/refresh.py
+++ /dev/null
@@ -1,45 +0,0 @@
-# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program. If not, see <http://www.gnu.org/licenses/>.
-
-# Try and minimize the refreshes we do.
-
-import threading
-from .request import RequestEntry
-from . import cfg
-from . import utils
-
-_rlock = threading.RLock()
-_count = 0
-
-
-def handle_external_event(command):
-	utils.log_debug("External event: '%s'" % command)
-	event_complete()
-	cfg.load()
-
-
-def event_add(params):
-	global _rlock
-	global _count
-	with _rlock:
-		if _count == 0:
-			_count += 1
-			r = RequestEntry(
-				-1, handle_external_event,
-				params, None, None, False)
-			cfg.worker_q.put(r)
-
-
-def event_complete():
-	global _rlock
-	global _count
-	with _rlock:
-		if _count > 0:
-			_count -= 1
-		return _count
diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
index 6d56443..e2ac63a 100644
--- a/daemons/lvmdbusd/udevwatch.py
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -9,7 +9,6 @@
 
 import pyudev
 import threading
-from .refresh import event_add
 from . import cfg
 
 observer = None
@@ -38,7 +37,7 @@ def filter_event(action, device):
 		refresh = True
 
 	if refresh:
-		event_add(('udev',))
+		cfg.event()
 
 
 def add():


