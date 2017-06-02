From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 2 Jun 2017 13:51:18 -0400
Subject: master - lvmdbusd: Prevent stall when update thread gets exception
Message-ID: <201706021751.v52HpIMg024404@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61420309ee34bb77318bf3913eb539b8f85adbda
Commit:        61420309ee34bb77318bf3913eb539b8f85adbda
Parent:        699ccc05cacc32b4707bf12dba4ccbb994469048
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 2 12:29:27 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 2 12:39:04 2017 -0500

lvmdbusd: Prevent stall when update thread gets exception

If during the process of fetching current lvm state we experience an
exception we fail to call set_result on the queued_requests we were
processing.  When this happens those threads block forever which causes
the service to stall infinitely.  Only clear the queued_requests after
we have called set_result.
---
 daemons/lvmdbusd/fetch.py |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 78c3a4b..c053685 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -82,10 +82,10 @@ class StateUpdate(object):
 
 	@staticmethod
 	def update_thread(obj):
+		queued_requests = []
 		while cfg.run.value != 0:
 			# noinspection PyBroadException
 			try:
-				queued_requests = []
 				refresh = True
 				emit_signal = True
 				cache_refresh = True
@@ -96,7 +96,7 @@ class StateUpdate(object):
 					wait = not obj.deferred
 					obj.deferred = False
 
-				if wait:
+				if len(queued_requests) == 0 and wait:
 					queued_requests.append(obj.queue.get(True, 2))
 
 				# Ok we have one or the deferred queue has some,
@@ -131,11 +131,17 @@ class StateUpdate(object):
 				for i in queued_requests:
 					i.set_result(num_changes)
 
+				# Only clear out the requests after we have given them a result
+				# otherwise we can orphan the waiting threads and they never
+				# wake up if we get an exception
+				queued_requests = []
+
 			except queue.Empty:
 				pass
 			except Exception:
 				st = traceback.format_exc()
 				log_error("update_thread exception: \n%s" % st)
+				cfg.blackbox.dump()
 
 	def __init__(self):
 		self.lock = threading.RLock()


