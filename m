From: tasleson <tasleson@fedoraproject.org>
Date: Tue,  8 Mar 2016 22:22:27 +0000 (UTC)
Subject: master - lvmdbus: Fix exception during exception handling
Message-ID: <20160308222227.7421260F6E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f5629302abd2cfae97ef821da274384806d085a
Commit:        3f5629302abd2cfae97ef821da274384806d085a
Parent:        90c5d470c2f3a67a90894846f7294ad31d7dc877
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Mar 8 15:57:15 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Mar 8 16:06:45 2016 -0600

lvmdbus: Fix exception during exception handling

Python 3.5 in F24 was throwing the following exception:

Traceback (most recent call last):
  File "/usr/lib/python3.5/site-packages/lvmdbusd/main.py", line 73, in process_request
    req.run_cmd()
  File "/usr/lib/python3.5/site-packages/lvmdbusd/request.py", line 73, in run_cmd
    self.register_error(-1, st)
  File "/usr/lib/python3.5/site-packages/lvmdbusd/request.py", line 123, in register_error
    self._reg_ending(None, error_rc, error)
  File "/usr/lib/python3.5/site-packages/lvmdbusd/request.py", line 115, in _reg_ending
    self.cb_error(self._rc_error)
  File "/usr/lib64/python3.5/site-packages/dbus/service.py", line 669, in <lambda>
    keywords[error_callback] = lambda exception: _method_reply_error(connection, message, exception)
  File "/usr/lib64/python3.5/site-packages/dbus/service.py", line 293, in _method_reply_error
    exception))
  File "/usr/lib64/python3.5/traceback.py", line 136, in format_exception_only
    return list(TracebackException(etype, value, None).format_exception_only())
  File "/usr/lib64/python3.5/traceback.py", line 442, in __init__
    if (exc_value and exc_value.__cause__ is not None
AttributeError: 'str' object has no attribute '__cause__'

This was caused because we were calling the dbus error callback with a
string instead of an actual exception.  On python 3.4 this was apparently
OK, but not with 3.5.  Corrected to pass the exception to error callback.
Change tested on both python 3.4 and 3.5.

Reported-by: Vratislav Podzimek <vpodzime@redhat.com>
Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/request.py |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index fba6580..6836131 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -64,13 +64,13 @@ class RequestEntry(object):
 		try:
 			result = self.method(*self.arguments)
 			self.register_result(result)
-		except Exception:
+		except Exception as e:
 			# Use the request entry to return the result as the client may
 			# have gotten a job by the time we hit an error
 			# Lets get the stacktrace and set that to the error message
 			st = traceback.format_exc()
 			log_error("Exception returned to client: \n%s" % st)
-			self.register_error(-1, st)
+			self.register_error(-1, str(e), e)
 
 	def is_done(self):
 		with self.lock:
@@ -87,7 +87,8 @@ class RequestEntry(object):
 				return self._result
 			return '/'
 
-	def _reg_ending(self, result, error_rc=0, error=None):
+	def _reg_ending(self, result, error_rc=0, error_msg=None,
+					error_exception=None):
 		with self.lock:
 			self.done = True
 			if self.timer_id != -1:
@@ -96,7 +97,7 @@ class RequestEntry(object):
 
 			self._result = result
 			self._rc = error_rc
-			self._rc_error = error
+			self._rc_error = error_msg
 
 			if not self._job:
 				# We finished and there is no job, so return result or error
@@ -112,15 +113,23 @@ class RequestEntry(object):
 							self.cb(result)
 				else:
 					if self.cb_error:
-						self.cb_error(self._rc_error)
+						if not error_exception:
+							if not error_msg:
+								error_exception = Exception(
+									"An error occurred, but no reason was "
+									"given, see service logs!")
+							else:
+								error_exception = Exception(error_msg)
+
+						self.cb_error(error_exception)
 			else:
 				# We have a job and it's complete, indicate that it's done.
 				# TODO: We need to signal the job is done too.
 				self._job.Complete = True
 				self._job = None
 
-	def register_error(self, error_rc, error):
-		self._reg_ending(None, error_rc, error)
+	def register_error(self, error_rc, error_message, error_exception):
+		self._reg_ending(None, error_rc, error_message, error_exception)
 
 	def register_result(self, result):
 		self._reg_ending(result)


