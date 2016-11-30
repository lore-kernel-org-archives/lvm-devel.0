From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:42 +0000 (UTC)
Subject: master - lvmdbusd: Emit signal on Job completion
Message-ID: <20161130215942.4EAC660DE9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=53ef4967192ce8bfe5eaebf8104a1f7cbf8ab020
Commit:        53ef4967192ce8bfe5eaebf8104a1f7cbf8ab020
Parent:        1d520909534e1a4e1adf2513a5061adfe631d6af
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 13:39:48 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbusd: Emit signal on Job completion

Added a properties changed signal on the job dbus object so that client
can wait for a signal that the job is complete instead of polling or
blocking on the wait method.
---
 daemons/lvmdbusd/job.py     |    8 +++++++-
 daemons/lvmdbusd/request.py |    1 -
 daemons/lvmdbusd/utils.py   |    5 +++++
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index ec6d6b6..609b747 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -8,7 +8,7 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 from .automatedproperties import AutomatedProperties
-from .utils import job_obj_path_generate, mt_async_result
+from .utils import job_obj_path_generate, mt_async_result, mt_run_no_wait
 from . import cfg
 from .cfg import JOB_INTERFACE
 import dbus
@@ -180,9 +180,15 @@ class Job(AutomatedProperties):
 	def Complete(self):
 		return dbus.Boolean(self.state.Complete)
 
+	@staticmethod
+	def _signal_complete(obj):
+		obj.PropertiesChanged(
+			JOB_INTERFACE, dict(Complete=dbus.Boolean(obj.state.Complete)), [])
+
 	@Complete.setter
 	def Complete(self, value):
 		self.state.Complete = value
+		mt_run_no_wait(Job._signal_complete, self)
 
 	@property
 	def GetError(self):
diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index ca45e8c..a2c2ac9 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -126,7 +126,6 @@ class RequestEntry(object):
 						mt_async_result(self.cb_error, error_exception)
 			else:
 				# We have a job and it's complete, indicate that it's done.
-				# TODO: We need to signal the job is done too.
 				self._job.Complete = True
 				self._job = None
 
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index abee659..b95f80a 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -515,6 +515,11 @@ def mt_async_result(call_back, results):
 	GLib.idle_add(_async_result, call_back, results)
 
 
+# Take the supplied function and run it on the main thread and not wait for
+# a result!
+def mt_run_no_wait(function, param):
+	GLib.idle_add(function, param)
+
 # Run the supplied function and arguments on the main thread and wait for them
 # to complete while allowing the ability to get the return value too.
 #


