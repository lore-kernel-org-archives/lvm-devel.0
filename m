From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 21:59:48 +0000 (UTC)
Subject: master - lvmdbustest.py: Remove redundant import
Message-ID: <20161130215948.897186063C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea2eb2df97252a5dc0f7fd27018171162d1e07ce
Commit:        ea2eb2df97252a5dc0f7fd27018171162d1e07ce
Parent:        b75d1a591c2ad3c85b9bc25139d2044f439e8cc7
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 14:54:39 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 15:59:06 2016 -0600

lvmdbustest.py: Remove redundant import

---
 test/dbus/lvmdbustest.py |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 11fa19f..2e3ec22 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -717,7 +717,6 @@ class TestDbusService(unittest.TestCase):
 
 	# noinspection PyUnresolvedReferences
 	def _wait_for_job(self, j_path):
-		import time
 		rc = None
 		j = ClientProxy(self.bus, j_path, interfaces=(JOB_INT, )).Job
 


