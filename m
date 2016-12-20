From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 20 Dec 2016 17:08:18 +0000 (UTC)
Subject: master - lvmdbusd: Use timeout_add instead
Message-ID: <20161220170818.D44C360E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7e1f973ccd1abfc0f868f0b9c2382c2034e1633
Commit:        a7e1f973ccd1abfc0f868f0b9c2382c2034e1633
Parent:        75568294be01f74ddadbf2c9bacf5d2fce219a44
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Dec 14 15:30:01 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Dec 20 11:06:57 2016 -0600

lvmdbusd: Use timeout_add instead

The function timeout_add_seconds has quite a bit of variability.  Using
timeout_add which specifies the timeout in ms instead of seconds.  Testing
shows that this is much more consistent which should improve clients that
are using shorter timeouts for the API and the connection.
---
 daemons/lvmdbusd/request.py |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 7c5da46..78392de 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -19,7 +19,6 @@ from .utils import log_error, mt_async_result
 class RequestEntry(object):
 	def __init__(self, tmo, method, arguments, cb, cb_error,
 			return_tuple=True, job_state=None):
-		self.tmo = tmo
 		self.method = method
 		self.arguments = arguments
 		self.cb = cb
@@ -35,23 +34,27 @@ class RequestEntry(object):
 		self._return_tuple = return_tuple
 		self._job_state = job_state
 
-		if self.tmo < 0:
+		if tmo < 0:
 			# Client is willing to block forever
 			pass
 		elif tmo == 0:
 			self._return_job()
 		else:
-			self.timer_id = GLib.timeout_add_seconds(
-				tmo, RequestEntry._request_timeout, self)
+			# Note: using 990 instead of 1000 for second to ms conversion to
+			# account for overhead.  Goal is to return just before the
+			# timeout amount has expired.  Better to be a little early than
+			# late.
+			self.timer_id = GLib.timeout_add(
+				tmo * 990, RequestEntry._request_timeout, self)
 
 	@staticmethod
 	def _request_timeout(r):
 		"""
 		Method which gets called when the timer runs out!
 		:param r:  RequestEntry which timed out
-		:return: Nothing
+		:return: Result of timer_expired
 		"""
-		r.timer_expired()
+		return r.timer_expired()
 
 	def _return_job(self):
 		# Return job is only called when we create a request object or when


