From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 26 May 2017 09:42:03 -0400
Subject: master - test: Fix dbus testing using testsuite
Message-ID: <201705261342.v4QDg3Dt024220@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=223c594f0e9e0248739a3bbb1c98fbf509140e6b
Commit:        223c594f0e9e0248739a3bbb1c98fbf509140e6b
Parent:        7687ab82c8d71e5d11c915a4dd390249b8124b9a
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 26 15:34:47 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 26 15:39:20 2017 +0200

test: Fix dbus testing using testsuite

- Must reread all objects as PVs might be removed.
- Never consider testsuite provided PVs nested, or tearDown fails to
  remove any outstanding VGs on them.
---
 test/dbus/lvmdbustest.py |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d9f0f8c..3dca9d5 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -70,8 +70,12 @@ def lv_n(suffix=None):
 	return g_prefix + rs(8, s)
 
 
+def _is_testsuite_pv(pv_name):
+	return g_prefix != "" and pv_name[-1].isdigit() and pv_name[:-1].endswith(g_prefix + "pv")
+
+
 def is_nested_pv(pv_name):
-	return pv_name.count('/') == 3
+	return pv_name.count('/') == 3 and not _is_testsuite_pv(pv_name)
 
 
 def _root_pv_name(res, pv_name):
@@ -241,6 +245,7 @@ class TestDbusService(unittest.TestCase):
 
 		# Check to make sure the PVs we had to start exist, else re-create
 		# them
+		self.objs, self.bus = get_objects()
 		if len(self.pvs) != len(self.objs[PV_INT]):
 			for p in self.pvs:
 				found = False


