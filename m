From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:37 +0000 (UTC)
Subject: master - lvmdbusd: Assign percentage on set
Message-ID: <20160919203837.DB531609C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed37b4a62669e0e511941984c52544b3ae87589d
Commit:        ed37b4a62669e0e511941984c52544b3ae87589d
Parent:        d18ea3f2cbbc53952f69ad52ca39835cebf4a847
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 19 14:30:04 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:32:47 2016 -0500

lvmdbusd: Assign percentage on set

---
 daemons/lvmdbusd/job.py |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index ec286aa..1158370 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -49,8 +49,6 @@ class JobState(object):
 		with self.rlock:
 			if self._request:
 				self._complete = self._request.is_done()
-				if self._complete:
-					self._percent = 100
 
 			return self._complete
 
@@ -58,6 +56,7 @@ class JobState(object):
 	def Complete(self, value):
 		with self.rlock:
 			self._complete = value
+			self._percent = 100
 			self._cond.notify_all()
 
 	@property


