From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 23:07:05 +0000 (UTC)
Subject: master - lvmdbustest.py: Add tag regression test
Message-ID: <20160829230705.5DA6E60DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=257ce5733e386dbf3b270ca0efffe744f8d888c5
Commit:        257ce5733e386dbf3b270ca0efffe744f8d888c5
Parent:        5392a612dc722fa9ca20959f362cd8c130b5ab48
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 17:59:42 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 17:59:42 2016 -0500

lvmdbustest.py: Add tag regression test

Add '-' back in as acceptable tag character
---
 test/dbus/lvmdbustest.py |   23 ++++++++++++++++++-----
 1 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 4327a96..ea3f220 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1107,13 +1107,10 @@ class TestDbusService(unittest.TestCase):
 				vg_proxy.Vg.LvCreateLinear(r + rs(8, '_lv'),
 					mib(4), False, -1, {})
 
-	# Wait until BZ https://bugzilla.redhat.com/show_bug.cgi?id=1370002
-	# is corrected before we add '-' in the allowable character set
-	#_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
-	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._+/=!:&#"
+	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
 
 	def _invalid_tag_characters(self):
-		bad_tag_ch_set = set(string.printable) - set(self._ALLOWABLE_TAG_CH + '-')
+		bad_tag_ch_set = set(string.printable) - set(self._ALLOWABLE_TAG_CH)
 		return ''.join(bad_tag_ch_set)
 
 	def test_invalid_tags(self):
@@ -1150,6 +1147,22 @@ class TestDbusService(unittest.TestCase):
 			self.assertEqual(i, len(vg_proxy.Vg.Tags), "%d != %d" %
 				(i, len(vg_proxy.Vg.Tags)))
 
+	def test_tag_regression(self):
+		mgr = self.objs[MANAGER_INT][0].Manager
+		pv_paths = [self.objs[PV_INT][0].object_path]
+
+		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_proxy = ClientProxy(self.bus, vg_path)
+
+		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'
+
+		r = vg_proxy.Vg.TagsAdd([tag], -1, {})
+		self.assertTrue(r == '/')
+		vg_proxy.update()
+
+		self.assertTrue(tag in vg_proxy.Vg.Tags, "%s not in %s" %
+						(tag, str(vg_proxy.Vg.Tags)))
+
 
 if __name__ == '__main__':
 	# Test forking & exec new each time


