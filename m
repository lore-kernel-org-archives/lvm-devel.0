From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 1 Mar 2017 18:59:02 -0500
Subject: master - lvmdbustest.py: Remove un-used variable
Message-ID: <201703012359.v21Nx2bG005135@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=26ca308ba91454ab34a5eefa8c24d8f70a7c4308
Commit:        26ca308ba91454ab34a5eefa8c24d8f70a7c4308
Parent:        7b0371e74ecb4ceab18e937508daa66a8d636259
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 1 17:29:40 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 1 17:47:04 2017 -0600

lvmdbustest.py:  Remove un-used variable

Not needed with new validation function.
---
 test/dbus/lvmdbustest.py |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c0a3d64..58d8d10 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -483,7 +483,6 @@ class TestDbusService(unittest.TestCase):
 		(vg, thin_pool) = self._create_raid5_thin_pool()
 
 		vg_name_start = vg.Name
-		mgr = self.objs[MANAGER_INT][0].Manager
 
 		# noinspection PyTypeChecker
 		self._verify_hidden_lookups(thin_pool.LvCommon, vg_name_start)


