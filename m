From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:42 +0000 (UTC)
Subject: master - lvmdbusd: Make job.Percent a double
Message-ID: <20160829202842.D265461884@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0985b2d0d45d82fbaac7112c0c575cb14792d021
Commit:        0985b2d0d45d82fbaac7112c0c575cb14792d021
Parent:        2bb09b4015ec85bb11b68a52e326a01ce3c8f98f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 24 22:39:30 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:55 2016 -0500

lvmdbusd: Make job.Percent a double

---
 daemons/lvmdbusd/job.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 7299583..ec286aa 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -105,7 +105,7 @@ class JobState(object):
 
 # noinspection PyPep8Naming
 class Job(AutomatedProperties):
-	_Percent_meta = ('y', JOB_INTERFACE)
+	_Percent_meta = ('d', JOB_INTERFACE)
 	_Complete_meta = ('b', JOB_INTERFACE)
 	_Result_meta = ('o', JOB_INTERFACE)
 	_GetError_meta = ('(is)', JOB_INTERFACE)
@@ -121,7 +121,7 @@ class Job(AutomatedProperties):
 
 	@property
 	def Percent(self):
-		return dbus.Byte(int(self.state.Percent))
+		return dbus.Double(float(self.state.Percent))
 
 	@Percent.setter
 	def Percent(self, value):


