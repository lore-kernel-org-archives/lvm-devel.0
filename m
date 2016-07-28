From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 28 Jul 2016 16:18:04 +0000 (UTC)
Subject: master - lvmdbusd: Fix hang for Job.Wait(n)
Message-ID: <20160728161804.49249609E3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20b21f4fd85532bd63a699aac4fc34f5786cf96d
Commit:        20b21f4fd85532bd63a699aac4fc34f5786cf96d
Parent:        8d959b6c75a6cc98691413ec4eab5b01e992d6c1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Jul 27 18:27:58 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jul 28 11:13:29 2016 -0500

lvmdbusd: Fix hang for Job.Wait(n)

When a client is doing a wait on a job, any other clients will hang
when trying to do anything with the service.  This is caused by
the wait code which  was placing the thread that handles
incoming dbus requests to sleep until either the timeout expired or
the job operation completed.

This change creates a thread for the wait request, so that the thread
processing incoming requests can continue to run.
---
 daemons/lvmdbusd/background.py |   30 +++++++++++++++++++++++++++++-
 daemons/lvmdbusd/job.py        |    8 +++++---
 2 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/background.py b/daemons/lvmdbusd/background.py
index 2c719fc..8078b66 100644
--- a/daemons/lvmdbusd/background.py
+++ b/daemons/lvmdbusd/background.py
@@ -13,7 +13,7 @@ from . import cfg
 import time
 from .cmdhandler import options_to_cli_args
 import dbus
-from .utils import pv_range_append, pv_dest_ranges, log_error
+from .utils import pv_range_append, pv_dest_ranges, log_error, log_debug
 import traceback
 
 _rlock = threading.RLock()
@@ -118,6 +118,7 @@ def background_reaper():
 				for i in range(num_threads, -1, -1):
 					_thread_list[i].join(0)
 					if not _thread_list[i].is_alive():
+						log_debug("Removing thread: %s" % _thread_list[i].name)
 						_thread_list.pop(i)
 
 		time.sleep(3)
@@ -171,3 +172,30 @@ def add(command, reporting_job):
 
 	with _rlock:
 		_thread_list.append(t)
+
+
+def wait_thread(job, timeout, cb, cbe):
+	# We need to put the wait on it's own thread, so that we don't block the
+	# entire dbus queue processing thread
+	try:
+		cb(job.state.Wait(timeout))
+	except Exception as e:
+		cbe("Wait exception: %s" % str(e))
+	return 0
+
+
+def add_wait(job, timeout, cb, cbe):
+
+	if timeout == 0:
+		# Users are basically polling, do not create thread
+		cb(job.Complete)
+	else:
+		t = threading.Thread(
+			target=wait_thread,
+			name="thread job.Wait: %s" % job.dbus_object_path(),
+			args=(job, timeout, cb, cbe)
+		)
+
+		t.start()
+		with _rlock:
+			_thread_list.append(t)
diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index d7f8187..520f9a8 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -13,6 +13,7 @@ from . import cfg
 from .cfg import JOB_INTERFACE
 import dbus
 import threading
+from . import background
 
 
 # noinspection PyPep8Naming
@@ -152,9 +153,10 @@ class Job(AutomatedProperties):
 
 	@dbus.service.method(dbus_interface=JOB_INTERFACE,
 							in_signature='i',
-							out_signature='b')
-	def Wait(self, timeout):
-		return self.state.Wait(timeout)
+							out_signature='b',
+							async_callbacks=('cb', 'cbe'))
+	def Wait(self, timeout, cb, cbe):
+		background.add_wait(self, timeout, cb, cbe)
 
 	@property
 	def Result(self):


