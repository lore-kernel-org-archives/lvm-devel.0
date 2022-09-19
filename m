From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:22 +0000 (GMT)
Subject: main - lvmdbusd: refactor and correct fetch thread logic
Message-ID: <20220919155822.D43D63858280@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5c41b94b841abe1ce3c23c814f7f7c31048b6e8
Commit:        e5c41b94b841abe1ce3c23c814f7f7c31048b6e8
Parent:        25abe41b00e1c9b525a1ff5e043b4b8507ba03cf
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 16:18:06 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: refactor and correct fetch thread logic

Simplify the fetch thread and correct the logic used for selecting the
options which are used when we batch update a state refresh.
---
 daemons/lvmdbusd/fetch.py | 53 +++++++++++++++++++++--------------------------
 1 file changed, 24 insertions(+), 29 deletions(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 6cf64f148..d1759f7dd 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -140,15 +140,29 @@ class StateUpdate(object):
 			except queue.Empty:
 				pass
 
+		def _load_args(requests):
+			"""
+			If we have multiple requests in the queue, they might not all have the same options.  If any of the requests
+			have an option set we need to honor it.
+			"""
+			refresh = any([r.refresh for r in requests])
+			emit_signal = any([r.emit_signal for r in requests])
+			cache_refresh = any([r.cache_refresh for r in requests])
+			log = any([r.log for r in requests])
+			need_main_thread = any([r.need_main_thread for r in requests])
+
+			return refresh, emit_signal, cache_refresh, log, need_main_thread
+
+		def _drain_queue(queued, incoming):
+			try:
+				while True:
+					queued.append(incoming.get(block=False))
+			except queue.Empty:
+				pass
+
 		while cfg.run.value != 0:
 			# noinspection PyBroadException
 			try:
-				refresh = True
-				emit_signal = True
-				cache_refresh = True
-				log = True
-				need_main_thread = True
-
 				with obj.lock:
 					wait = not obj.deferred
 					obj.deferred = False
@@ -156,36 +170,17 @@ class StateUpdate(object):
 				if len(queued_requests) == 0 and wait:
 					# Note: If we don't have anything for 2 seconds we will
 					# get a queue.Empty exception raised here
-					queued_requests.append(obj.queue.get(True, 2))
+					queued_requests.append(obj.queue.get(block=True, timeout=2))
 
 				# Ok we have one or the deferred queue has some,
-				# check if any others
-				try:
-					while True:
-						queued_requests.append(obj.queue.get(False))
-
-				except queue.Empty:
-					pass
+				# check if any others and grab them too
+				_drain_queue(queued_requests, obj.queue)
 
 				if len(queued_requests) > 1:
 					log_debug("Processing %d updates!" % len(queued_requests),
 							'bg_black', 'fg_light_green')
 
-				# We have what we can, run the update with the needed options
-				for i in queued_requests:
-					if not i.refresh:
-						refresh = False
-					if not i.emit_signal:
-						emit_signal = False
-					if not i.cache_refresh:
-						cache_refresh = False
-					if not i.log:
-						log = False
-					if not i.need_main_thread:
-						need_main_thread = False
-
-				num_changes = load(refresh, emit_signal, cache_refresh, log,
-									need_main_thread)
+				num_changes = load(*_load_args(queued_requests))
 				# Update is done, let everyone know!
 				set_results(num_changes)
 

