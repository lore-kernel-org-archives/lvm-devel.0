From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:44:26 +0000 (UTC)
Subject: master - lvmdbusd: Reduce unnecessary state refreshes
Message-ID: <20160225224426.CFCF66109C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1bc68beb4e493a9c1a52750e99d50f874ca89d9
Commit:        f1bc68beb4e493a9c1a52750e99d50f874ca89d9
Parent:        045d086a570d327b00a4a06d139b387d059ade60
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Feb 25 14:57:12 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Feb 25 16:43:55 2016 -0600

lvmdbusd: Reduce unnecessary state refreshes

When we use udev or have lvm call back into the dbus service when a
change occurs, even if that change originated from the dbus service
we end up refreshing the state of the system twice which is not
needed or wanted.  This change handles this case by removing any
pending refreshes in the worker queue if the state of the system
was just updated.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/lvmdb.py |    3 +--
 daemons/lvmdbusd/main.py  |   43 ++++++++++++++++++++++++++++++++++++-------
 2 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index 46e2099..132bee7 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -272,10 +272,9 @@ class DataStore(object):
 		:param log  Add debug log entry/exit messages
 		:return: None
 		"""
-
+		self.num_refreshes += 1
 		if log:
 			log_debug("lvmdb - refresh entry")
-			self.num_refreshes += 1
 
 		# Grab everything first then parse it
 		_raw_pvs = cmdhandler.pv_retrieve_with_segs()
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index c9211f7..6cabcc4 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -24,11 +24,11 @@ from .manager import Manager
 from .background import background_reaper
 import traceback
 import queue
-import sys
 from . import udevwatch
 from .utils import log_debug
 import argparse
 import os
+from .refresh import handle_external_event, event_complete
 
 
 class Lvm(objectmanager.ObjectManager):
@@ -36,6 +36,30 @@ class Lvm(objectmanager.ObjectManager):
 		super(Lvm, self).__init__(object_path, BASE_INTERFACE)
 
 
+def _discard_pending_refreshes():
+	# We just handled a refresh, if we have any in the queue they can be
+	# removed because by definition they are older than the refresh we just did.
+	# As we limit the number of refreshes getting into the queue
+	# we should only ever have one to remove.
+	requests = []
+	while not cfg.worker_q.empty():
+		try:
+			r = cfg.worker_q.get(block=False)
+			if r.method != handle_external_event:
+				requests.append(r)
+			else:
+				# Make sure we make this event complete even though it didn't
+				# run, otherwise no other events will get processed
+				event_complete()
+				break
+		except queue.Empty:
+			break
+
+	# Any requests we removed, but did not discard need to be re-queued
+	for r in requests:
+		cfg.worker_q.put(r)
+
+
 def process_request():
 	while cfg.run.value != 0:
 		try:
@@ -50,16 +74,21 @@ def process_request():
 
 			end = cfg.db.num_refreshes
 
-			if end - start > 1:
-				log_debug(
-					"Inspect method %s for too many refreshes" %
-					(str(req.method)))
+			num_refreshes = end - start
+
+			if num_refreshes > 0:
+				_discard_pending_refreshes()
+
+				if num_refreshes > 1:
+					log_debug(
+						"Inspect method %s for too many refreshes" %
+						(str(req.method)))
 			log_debug("Complete ")
 		except queue.Empty:
 			pass
 		except Exception:
-			traceback.print_exc(file=sys.stdout)
-			pass
+			st = traceback.format_exc()
+			utils.log_error("process_request exception: \n%s" % st)
 
 
 def main():


