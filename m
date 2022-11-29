From: Tony Asleson <tasleson@sourceware.org>
Date: Tue, 29 Nov 2022 19:01:35 +0000 (GMT)
Subject: main - lvmdbustest: Add test to ensure error collection
Message-ID: <20221129190135.210A53858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61917fbac2302e1f0c56aa75437e6ea72834b30d
Commit:        61917fbac2302e1f0c56aa75437e6ea72834b30d
Parent:        a02268e93800c0390650cbf12061b705acfc2196
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 09:57:20 2022 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 29 12:56:55 2022 -0600

lvmdbustest: Add test to ensure error collection

Recreates https://bugzilla.redhat.com/show_bug.cgi?id=2145114
---
 test/dbus/lvmdbustest.py | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 9582fe674..c07963525 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -2468,6 +2468,27 @@ class TestDbusService(unittest.TestCase):
 			if rc == "/":
 				self._pv_create(pv_device_path)
 
+	def test_stderr_collection(self):
+		lv_name = lv_n()
+		vg = self._vg_create().Vg
+		(object_path, job_path) = vg.LvCreate(
+			dbus.String(lv_name), dbus.UInt64(vg.SizeBytes * 2),
+			dbus.Array([], signature='(ott)'), dbus.Int32(0),
+			EOD)
+
+		self.assertTrue(object_path == '/')
+		self.assertTrue(job_path != '/')
+
+		j = ClientProxy(self.bus, job_path, interfaces=(JOB_INT,)).Job
+		while True:
+			j.update()
+			if j.Complete:
+				(ec, error_msg) = j.GetError
+				self.assertTrue("insufficient free space" in error_msg, error_msg)
+				break
+			else:
+				time.sleep(0.1)
+
 
 class AggregateResults(object):
 

