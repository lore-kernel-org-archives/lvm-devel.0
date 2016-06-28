From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:29 +0000 (UTC)
Subject: master - lvmdbusd: request.py, initialize _job to None
Message-ID: <20160628192429.479F360FC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5274c2f11b9e262588c1dec86609e829618d2e76
Commit:        5274c2f11b9e262588c1dec86609e829618d2e76
Parent:        4f26eae40f07399f11a2abe675aef850b0dd5239
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 28 11:45:05 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:09:28 2016 -0500

lvmdbusd: request.py, initialize _job to None

_job is a job object, not a boolean so initialize it to None instead.
---
 daemons/lvmdbusd/request.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index 02f8c88..3e29b82 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -29,7 +29,7 @@ class RequestEntry(object):
 		self.lock = threading.RLock()
 		self.done = False
 		self._result = None
-		self._job = False
+		self._job = None
 		self._rc = 0
 		self._rc_error = None
 		self._return_tuple = return_tuple


