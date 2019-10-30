From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:49 -0400
Subject: master - lvmdbusd: Debug msg. improvements.
Message-ID: <201910301545.x9UFjnT1017006@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bbf97757736b49065bd6944d36e7a6db6f3aa7e
Commit:        1bbf97757736b49065bd6944d36e7a6db6f3aa7e
Parent:        4dcb36aba4160ffe9ae90c93642e717e813e4779
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Oct 11 10:46:22 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Debug msg. improvements.

---
 daemons/lvmdbusd/main.py    |   10 +++++-----
 daemons/lvmdbusd/manager.py |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 9988143..b0a82d4 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -44,10 +44,10 @@ def process_request():
 		try:
 			req = cfg.worker_q.get(True, 5)
 			log_debug(
-				"Running method: %s with args %s" %
-				(str(req.method), str(req.arguments)))
+				"Method start: %s with args %s (callback = %s)" %
+				(str(req.method), str(req.arguments), str(req.cb)))
 			req.run_cmd()
-			log_debug("Method complete ")
+			log_debug("Method complete: %s" % str(req.method))
 		except queue.Empty:
 			pass
 		except Exception:
@@ -159,8 +159,8 @@ def main():
 
 	# Using a thread to process requests, we cannot hang the dbus library
 	# thread that is handling the dbus interface
-	thread_list.append(threading.Thread(target=process_request,
-										name='process_request'))
+	thread_list.append(
+		threading.Thread(target=process_request, name='process_request'))
 
 	# Have a single thread handling updating lvm and the dbus model so we
 	# don't have multiple threads doing this as the same time
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 8de05db..2857e9a 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -107,10 +107,10 @@ class Manager(AutomatedProperties):
 		rc = cfg.load(log=False)
 
 		if rc != 0:
-			utils.log_debug('Manager.Refresh - exit %d' % (rc),
+			utils.log_debug('Manager.Refresh - exit %d %d' % (rc, lc),
 							'bg_black', 'fg_light_red')
 		else:
-			utils.log_debug('Manager.Refresh - exit %d' % (rc))
+			utils.log_debug('Manager.Refresh - exit %d %d' % (rc, lc))
 		return rc + lc
 
 	@dbus.service.method(


