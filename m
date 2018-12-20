From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 20 Dec 2018 11:28:19 -0500
Subject: master - lvmdbusd: Exit daemon when unable to retrieve state
Message-ID: <201812201628.wBKGSJ79009356@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab1f1a306bf8e146c1221786a1c1c24f8b71a377
Commit:        ab1f1a306bf8e146c1221786a1c1c24f8b71a377
Parent:        3320ab8334794684b4d324bb78d0b293a27287a6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Dec 18 09:49:36 2018 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Dec 20 10:27:30 2018 -0600

lvmdbusd: Exit daemon when unable to retrieve state

In some cases we get stuck where we are unable to retrieve the current
state of lvm as we are encountering an error.  When the error is
persistent we will log and exit the daemon instead of consuming vast
amounts of resources.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/cfg.py   |   10 ++++++++++
 daemons/lvmdbusd/fetch.py |   19 ++++++++++++++++++-
 2 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 771909f..be497d0 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -87,3 +87,13 @@ blackbox = None
 
 # RequestEntry ctor
 create_request_entry = None
+
+
+def exit_daemon():
+    """
+    Exit the daemon cleanly
+    :return:
+    """
+    if run and loop:
+        run.value = 0
+        loop.quit()
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 69a4aae..e8f3521 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -14,6 +14,7 @@ from . import cfg
 from .utils import MThreadRunner, log_debug, log_error
 import threading
 import queue
+import time
 import traceback
 
 
@@ -82,6 +83,8 @@ class StateUpdate(object):
 
 	@staticmethod
 	def update_thread(obj):
+		exception_count = 0
+
 		queued_requests = []
 		while cfg.run.value != 0:
 			# noinspection PyBroadException
@@ -136,12 +139,26 @@ class StateUpdate(object):
 				# wake up if we get an exception
 				queued_requests = []
 
+				# We retrieved OK, clear exception count
+				exception_count = 0
+
 			except queue.Empty:
 				pass
-			except Exception:
+			except Exception as e:
 				st = traceback.format_exc()
 				log_error("update_thread exception: \n%s" % st)
 				cfg.blackbox.dump()
+				exception_count += 1
+				if exception_count >= 5:
+					for i in queued_requests:
+						i.set_result(e)
+
+					log_error("Too many errors in update_thread, exiting daemon")
+					cfg.exit_daemon()
+
+				else:
+					# Slow things down when encountering errors
+					time.sleep(1)
 
 	def __init__(self):
 		self.lock = threading.RLock()


