From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:04 +0000 (GMT)
Subject: main - lvmdbustest: Add test removing incomplete job
Message-ID: <20220919155804.A8D083858412@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f4cb78a4e1ac2cf7cc30d76e86765618071b2813
Commit:        f4cb78a4e1ac2cf7cc30d76e86765618071b2813
Parent:        2ca4a2dbf3d35528f8173916aed77fd277f23f18
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 17 12:14:02 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbustest: Add test removing incomplete job

When you try to remove a job that is incomplete you get a dbus exception.
Test for this error condition.
---
 test/dbus/lvmdbustest.py | 38 ++++++++++++++++++++++++++++++--------
 1 file changed, 30 insertions(+), 8 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index d67298fe9..878300a97 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1115,13 +1115,7 @@ class TestDbusService(unittest.TestCase):
 		vg_path = self._wait_for_job(vg_job)
 		self._validate_lookup(vg_name, vg_path)
 
-	def _test_expired_timer(self, num_lvs):
-		rc = False
-
-		# In small configurations lvm is pretty snappy, so let's create a VG
-		# add a number of LVs and then remove the VG and all the contained
-		# LVs which appears to consistently run a little slow.
-
+	def _create_num_lvs(self, num_lvs):
 		vg_proxy = self._vg_create(self._all_pv_object_paths())
 
 		for i in range(0, num_lvs):
@@ -1140,8 +1134,18 @@ class TestDbusService(unittest.TestCase):
 					"%s/%s" % (vg_proxy.Vg.Name, lv_name), lv_path)
 
 			else:
-				# We ran out of space, test will probably fail
+				# We ran out of space, test(s) may fail
 				break
+		return vg_proxy
+
+	def _test_expired_timer(self, num_lvs):
+		rc = False
+
+		# In small configurations lvm is pretty snappy, so let's create a VG
+		# add a number of LVs and then remove the VG and all the contained
+		# LVs which appears to consistently run a little slow.
+
+		vg_proxy = self._create_num_lvs(num_lvs)
 
 		# Make sure that we are honoring the timeout
 		start = time.time()
@@ -2105,6 +2109,24 @@ class TestDbusService(unittest.TestCase):
 		self.assertTrue(rc == 0)
 		self._log_file_option()
 
+	def test_delete_non_complete_job(self):
+		# Let's create a vg with a number of lvs and then delete it all
+		# to hopefully create a long-running job.
+		vg_proxy = self._create_num_lvs(64)
+		job_path = vg_proxy.Vg.Remove(dbus.Int32(0), EOD)
+		self.assertNotEqual(job_path, "/")
+
+		# Try to delete the job expecting an exception
+		job_proxy = ClientProxy(self.bus, job_path, interfaces=(JOB_INT,)).Job
+		with self.assertRaises(dbus.exceptions.DBusException):
+			try:
+				job_proxy.Remove()
+			except dbus.exceptions.DBusException as e:
+				# Verify we got the expected text in exception
+				self.assertTrue('Job is not complete!' in str(e))
+				raise e
+
+
 class AggregateResults(object):
 
 	def __init__(self):

