From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:33 +0000 (GMT)
Subject: main - lvmdbusd: Add a retries during initial load
Message-ID: <20230310185233.43176385842E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66e79aab367621cbe76bf1e080d6f8693922ea07
Commit:        66e79aab367621cbe76bf1e080d6f8693922ea07
Parent:        9c3b91a513b70e74f21ca40e73f9ad7e3578ac48
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 11:29:58 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbusd: Add a retries during initial load

When the daemon is starting we do an initial fetch of lvm state.  If we
happened to get some type of failure with lvm during this time we would
exit.  During error injection testing this happened enough that
the unit tests were unable to finish.  Add retries to ensure we can get
started during error injection testing.
---
 daemons/lvmdbusd/fetch.py | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 9da62590a..9807da934 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -228,8 +228,17 @@ class StateUpdate(object):
 		self.queue = queue.Queue()
 		self.deferred = False
 
-		# Do initial load
-		load(refresh=False, emit_signal=False, need_main_thread=False)
+		# Do initial load, with retries.  During error injection testing we can and do fail here.
+		count = 0
+		need_refresh = False  # First attempt we are building from new, any subsequent will be true
+		while count < 5:
+			try:
+				load(refresh=need_refresh, emit_signal=False, need_main_thread=False)
+				break
+			except LvmBug as bug:
+				count += 1
+				need_refresh = True
+				log_error("We encountered an lvm bug on initial load, trying again %s" % str(bug))
 
 		self.thread = threading.Thread(target=StateUpdate.update_thread,
 										args=(self,),

