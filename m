From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  6 May 2015 13:53:22 +0000 (UTC)
Subject: master - Python: Improve lv property test coverage
Message-ID: <20150506135322.36C4960C24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d35c69b06ebe4b51edf277610eb803d23aba11d
Commit:        6d35c69b06ebe4b51edf277610eb803d23aba11d
Parent:        dc5190de74893ede7d3170b861ce8ae9327ecfae
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue May 5 13:48:52 2015 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed May 6 08:51:05 2015 -0500

Python: Improve lv property test coverage

Improve the python unit test case to cover all of the properties of a LV and
the properties of a LV segment.

In addition we also add a 'tag' to the lv so that we can retrieve it
using the 'lv_tags' property to ensure that this works as expected.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/api/python_lvm_unit.py |   56 ++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 53 insertions(+), 3 deletions(-)

diff --git a/test/api/python_lvm_unit.py b/test/api/python_lvm_unit.py
index e66ebda..6fc1963 100755
--- a/test/api/python_lvm_unit.py
+++ b/test/api/python_lvm_unit.py
@@ -21,7 +21,7 @@ import itertools
 import sys
 
 if sys.version_info[0] > 2:
-    long = int
+	long = int
 
 # Set of basic unit tests for the python bindings.
 #
@@ -309,7 +309,11 @@ class TestLvm(unittest.TestCase):
 	def _test_prop(self, prop_obj, prop, var_type, settable):
 		result = prop_obj.getProperty(prop)
 
-		self.assertEqual(type(result[0]), var_type)
+		#If we have no string value we can get a None type back
+		if result[0] is not None:
+			self.assertEqual(type(result[0]), var_type)
+		else:
+			self.assertTrue(str == var_type)
 		self.assertEqual(type(result[1]), bool)
 		self.assertTrue(result[1] == settable)
 
@@ -332,7 +336,53 @@ class TestLvm(unittest.TestCase):
 		lv_name = 'lv_test'
 		TestLvm._create_thin_lv(TestLvm._get_pv_device_names(), lv_name)
 		lv, vg = TestLvm._get_lv(None, lv_name)
-		self._test_prop(lv, 'seg_count', long, False)
+
+		lv_seg_properties = [
+			('chunk_size', long, False), ('devices', str, False),
+			('discards', str, False), ('region_size', long, False),
+			('segtype', str, False), ('seg_pe_ranges', str, False),
+			('seg_size', long, False), ('seg_size_pe', long, False),
+			('seg_start', long, False), ('seg_start_pe', long, False),
+			('seg_tags', str, False), ('stripes', long, False),
+			('stripe_size', long, False), ('thin_count', long, False),
+			('transaction_id', long, False), ('zero', long, False)]
+
+		lv_properties = [
+			('convert_lv', str, False), ('copy_percent', long, False),
+			('data_lv', str, False), ('lv_attr', str, False),
+			('lv_host', str, False), ('lv_kernel_major', long, False),
+			('lv_kernel_minor', long, False),
+			('lv_kernel_read_ahead', long, False),
+			('lv_major', long, False), ('lv_minor', long, False),
+			('lv_name', str, False), ('lv_path', str, False),
+			('lv_profile', str, False), ('lv_read_ahead', long, False),
+			('lv_size', long, False), ('lv_tags', str, False),
+			('lv_time', str, False), ('lv_uuid', str, False),
+			('metadata_lv', str, False), ('mirror_log', str, False),
+			('lv_modules', str, False), ('move_pv', str, False),
+			('origin', str, False), ('origin_size', long, False),
+			('pool_lv', str, False), ('raid_max_recovery_rate', long, False),
+			('raid_min_recovery_rate', long, False),
+			('raid_mismatch_count', long, False),
+			('raid_sync_action', str, False),
+			('raid_write_behind', long, False), ('seg_count', long, False),
+			('snap_percent', long, False), ('sync_percent', long, False)]
+
+		# Generic test case, make sure we get what we expect
+		for t in lv_properties:
+			self._test_prop(lv, *t)
+
+		segments = lv.listLVsegs()
+		if segments and len(segments):
+			for s in segments:
+				for t in lv_seg_properties:
+					self._test_prop(s, *t)
+
+		# Test specific cases
+		tag = 'hello_world'
+		lv.addTag(tag)
+		tags = lv.getProperty('lv_tags')
+		self.assertTrue(tag in tags[0])
 		vg.close()
 
 	def test_lv_tags(self):


