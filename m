From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  8 Mar 2016 22:22:29 +0000 (UTC)
Subject: master - lvmdbus: Fix deprecated warnings for GObject use
Message-ID: <20160308222229.9EBC460F6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d19c14c28b24dded999d4bf50a4638581c649f5
Commit:        6d19c14c28b24dded999d4bf50a4638581c649f5
Parent:        3f5629302abd2cfae97ef821da274384806d085a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Mar 8 16:04:44 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Mar 8 16:07:35 2016 -0600

lvmdbus:  Fix deprecated warnings for GObject use

While running on F24 a number of warnings were being emitted from using the
deprecated GObject instead of GLib.  Tested on python 3.4 and 3.5.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/main.py    |    5 ++---
 daemons/lvmdbusd/request.py |    6 +++---
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 92006d0..aa16a2e 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -18,7 +18,7 @@ import signal
 import dbus
 from . import lvmdb
 # noinspection PyUnresolvedReferences
-from gi.repository import GObject
+from gi.repository import GLib
 from .fetch import load
 from .manager import Manager
 from .background import background_reaper
@@ -123,7 +123,6 @@ def main():
 			pass
 
 	dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
-	GObject.threads_init()
 	dbus.mainloop.glib.threads_init()
 
 	if use_session:
@@ -148,7 +147,7 @@ def main():
 	thread_list.append(threading.Thread(target=process_request))
 
 	cfg.load(refresh=False, emit_signal=False)
-	cfg.loop = GObject.MainLoop()
+	cfg.loop = GLib.MainLoop()
 
 	for process in thread_list:
 		process.damon = True
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 6836131..cf258f1 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -9,7 +9,7 @@
 
 import threading
 # noinspection PyUnresolvedReferences
-from gi.repository import GObject
+from gi.repository import GLib
 from .job import Job
 from . import cfg
 import traceback
@@ -40,7 +40,7 @@ class RequestEntry(object):
 		elif tmo == 0:
 			self._return_job()
 		else:
-			self.timer_id = GObject.timeout_add_seconds(
+			self.timer_id = GLib.timeout_add_seconds(
 				tmo, RequestEntry._request_timeout, self)
 
 	@staticmethod
@@ -93,7 +93,7 @@ class RequestEntry(object):
 			self.done = True
 			if self.timer_id != -1:
 				# Try to prevent the timer from firing
-				GObject.source_remove(self.timer_id)
+				GLib.source_remove(self.timer_id)
 
 			self._result = result
 			self._rc = error_rc


