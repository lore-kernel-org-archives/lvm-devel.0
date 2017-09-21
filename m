From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 21 Sep 2017 15:36:51 -0400
Subject: master - lvmdbusd: Fix hang in MThreadRunner
Message-ID: <201709211936.v8LJap7h015540@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3965d392cc1cf1b29c4fcd6f2effb925d8df550
Commit:        e3965d392cc1cf1b29c4fcd6f2effb925d8df550
Parent:        096fcb5a6e373763bcdf1d182456f206c06cec43
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Sep 20 15:46:16 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 21 14:35:36 2017 -0500

lvmdbusd: Fix hang in MThreadRunner

When executing in the main thread, if we encounter an exception we
will bypass the notify_all call on the condition and the calling thread
never wakes up.

@staticmethod
    def runner(obj):
        # noinspection PyProtectedMember
Exception thrown here
 ----> obj._run()
So the following code doesn't run, which causes calling thread to hang
	with obj.cond:
            obj.function_complete = True
            obj.cond.notify_all()

Additionally for some unknown reason the stderr is lost.
Best guess is it's something to do with scheduling a python function
into the GLib.idle_add.  That made finding issue quite difficult.
---
 daemons/lvmdbusd/utils.py |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 170824d..98fd017 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -20,7 +20,7 @@ from lvmdbusd import cfg
 # noinspection PyUnresolvedReferences
 from gi.repository import GLib
 import threading
-
+import traceback
 
 STDOUT_TTY = os.isatty(sys.stdout.fileno())
 
@@ -568,6 +568,7 @@ class MThreadRunner(object):
 	def __init__(self, function, *args):
 		self.f = function
 		self.rc = None
+		self.exception = None
 		self.args = args
 		self.function_complete = False
 		self.cond = threading.Condition(threading.Lock())
@@ -577,13 +578,21 @@ class MThreadRunner(object):
 		with self.cond:
 			if not self.function_complete:
 				self.cond.wait()
+		if self.exception:
+			raise self.exception
 		return self.rc
 
 	def _run(self):
-		if len(self.args):
-			self.rc = self.f(*self.args)
-		else:
-			self.rc = self.f()
+		try:
+			if len(self.args):
+				self.rc = self.f(*self.args)
+			else:
+				self.rc = self.f()
+		except BaseException as be:
+			self.exception = be
+			st = traceback.format_exc()
+			log_error("MThreadRunner: exception \n %s" % st)
+			log_error("Exception will be raised in calling thread!")
 
 
 def _remove_objects(dbus_objects_rm):


