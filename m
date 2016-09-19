From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:20 +0000 (UTC)
Subject: master - lvmdbusd: Vg.LvCreate* methods, correct return type
Message-ID: <20160919203820.DE57960CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac2fc7a366d0e1e5b23115b34b7773eaf7334076
Commit:        ac2fc7a366d0e1e5b23115b34b7773eaf7334076
Parent:        72abf692e5b4f503ca9b52725df020342075c32f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Sep 16 14:00:14 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:31:04 2016 -0500

lvmdbusd: Vg.LvCreate* methods, correct return type

The methods were returning an instance of the object instead of the
object path which was causing an exception when the result was returned
with the job object as we are explicity trying to return an object path.

Unit test added which re-creates the issue and verifies the fix.
---
 daemons/lvmdbusd/vg.py   |    2 +-
 test/dbus/lvmdbustest.py |   11 +++++++++++
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 3b35873..70ccad6 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -146,7 +146,7 @@ class Vg(AutomatedProperties):
 	@staticmethod
 	def fetch_new_lv(vg_name, lv_name):
 		cfg.load()
-		return cfg.om.get_object_by_lvm_id("%s/%s" % (vg_name, lv_name))
+		return cfg.om.get_object_path_by_lvm_id("%s/%s" % (vg_name, lv_name))
 
 	@staticmethod
 	def _rename(uuid, vg_name, new_name, rename_options):
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index ea3f220..6943da5 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -387,6 +387,17 @@ class TestDbusService(unittest.TestCase):
 			(rs(8, '_lv'), mib(4),
 			dbus.Array([], '(ott)'), -1, {}), vg)
 
+	def test_lv_create_job(self):
+
+		vg = self._vg_create().Vg
+		(object_path, job_path) = vg.LvCreate(rs(8, '_lv'), mib(4),
+			dbus.Array([], '(ott)'), 0, {})
+
+		self.assertTrue(object_path == '/')
+		self.assertTrue(job_path != '/')
+		object_path = self._wait_for_job(job_path)
+		self.assertTrue(object_path != '/')
+
 	def test_lv_create_linear(self):
 
 		vg = self._vg_create().Vg


