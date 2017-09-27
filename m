From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 27 Sep 2017 08:48:12 -0400
Subject: master - lvmdbusd: Give threads names
Message-ID: <201709271248.v8RCmCGs023309@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=60e3dbd6d50ce2c28206c96f824a5afc9bb287e6
Commit:        60e3dbd6d50ce2c28206c96f824a5afc9bb287e6
Parent:        2074094e778bfc298fb4cb184b6005e40acd1159
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 25 15:18:43 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Sep 27 07:45:00 2017 -0500

lvmdbusd: Give threads names

This will allow easier debug.
---
 daemons/lvmdbusd/background.py |    3 ++-
 daemons/lvmdbusd/fetch.py      |    3 ++-
 daemons/lvmdbusd/main.py       |    3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 90e8b68..3b77a7c 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -158,5 +158,6 @@ def _run_cmd(req):
 
 
 def cmd_runner(request):
-	t = threading.Thread(target=_run_cmd, args=(request,))
+	t = threading.Thread(target=_run_cmd, args=(request,),
+							name="cmd_runner %s" % str(request.method))
 	t.start()
diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index c053685..69a4aae 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -152,7 +152,8 @@ class StateUpdate(object):
 		load(refresh=False, emit_signal=False, need_main_thread=False)
 
 		self.thread = threading.Thread(target=StateUpdate.update_thread,
-										args=(self,))
+										args=(self,),
+										name="StateUpdate.update_thread")
 
 	def load(self, refresh=True, emit_signal=True, cache_refresh=True,
 					log=True, need_main_thread=True):
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index ff97683..dc31b6f 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -138,7 +138,8 @@ def main():
 
 	# Using a thread to process requests, we cannot hang the dbus library
 	# thread that is handling the dbus interface
-	thread_list.append(threading.Thread(target=process_request))
+	thread_list.append(threading.Thread(target=process_request,
+										name='process_request'))
 
 	# Have a single thread handling updating lvm and the dbus model so we
 	# don't have multiple threads doing this as the same time


