From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 20 Dec 2016 17:08:14 +0000 (UTC)
Subject: master - lvmdbusd: Remove un-needed main thread execution
Message-ID: <20161220170814.9C22A60E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6fe6e8053a136af45174f153c00d404995af6e1c
Commit:        6fe6e8053a136af45174f153c00d404995af6e1c
Parent:        f47da0ad234118f4a7a5e64b7a8480f6afd8e1de
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Dec 12 16:13:27 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Dec 20 11:06:57 2016 -0600

lvmdbusd: Remove un-needed main thread execution

---
 daemons/lvmdbusd/request.py |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index a2c2ac9..7c5da46 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -54,12 +54,15 @@ class RequestEntry(object):
 		r.timer_expired()
 
 	def _return_job(self):
+		# Return job is only called when we create a request object or when
+		# we pop a timer.  In both cases we are running in the correct context
+		# and do not need to schedule the call back in main context.
 		self._job = Job(self, self._job_state)
 		cfg.om.register_object(self._job, True)
 		if self._return_tuple:
-			mt_async_result(self.cb, ('/', self._job.dbus_object_path()))
+			self.cb(('/', self._job.dbus_object_path()))
 		else:
-			mt_async_result(self.cb, self._job.dbus_object_path())
+			self.cb(self._job.dbus_object_path())
 
 	def run_cmd(self):
 		try:


