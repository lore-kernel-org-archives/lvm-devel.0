From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:44:03 -0400
Subject: master - lvmdbusdtest.py: Use common function for tag add
Message-ID: <201910301544.x9UFi3fo016639@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=22a22a735fef7bcd0f1acc80e99f500925e3572c
Commit:        22a22a735fef7bcd0f1acc80e99f500925e3572c
Parent:        62136c056a506568ede876ce41e826478399085b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 15:05:37 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusdtest.py: Use common function for tag add

---
 test/dbus/lvmdbustest.py |   40 +++++++++++++++-------------------------
 1 files changed, 15 insertions(+), 25 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index da1fc69..0384d5e 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1715,23 +1715,25 @@ class TestDbusService(unittest.TestCase):
 						dbus.Int32(g_tmo),
 						EOD))
 
+	def _tag_add_common(self, vg_proxy, tag):
+		tmp = self.handle_return(
+			vg_proxy.Vg.TagsAdd(
+				dbus.Array([tag], 's'),
+				dbus.Int32(g_tmo),
+				EOD))
+		self.assertTrue(tmp == '/')
+		vg_proxy.update()
+
+		self.assertTrue(
+			tag in vg_proxy.Vg.Tags,
+			"%s not in %s" % (tag, str(vg_proxy.Vg.Tags)))
+
 	def test_tag_names(self):
 		vg_proxy = self._vg_create()
 
 		for i in range(1, 64):
 			tag = rs(i, "", self._ALLOWABLE_TAG_CH)
-
-			tmp = self.handle_return(
-				vg_proxy.Vg.TagsAdd(
-					dbus.Array([tag], 's'),
-					dbus.Int32(g_tmo),
-					EOD))
-			self.assertTrue(tmp == '/')
-			vg_proxy.update()
-
-			self.assertTrue(
-				tag in vg_proxy.Vg.Tags,
-				"%s not in %s" % (tag, str(vg_proxy.Vg.Tags)))
+			self._tag_add_common(vg_proxy, tag)
 
 			self.assertEqual(
 				i, len(vg_proxy.Vg.Tags),
@@ -1739,20 +1741,8 @@ class TestDbusService(unittest.TestCase):
 
 	def test_tag_regression(self):
 		vg_proxy = self._vg_create()
-
 		tag = '--h/K.6g0A4FOEatf3+k_nI/Yp&L_u2oy-=j649x:+dUcYWPEo6.IWT0c'
-
-		tmp = self.handle_return(
-			vg_proxy.Vg.TagsAdd(
-				dbus.Array([tag], 's'),
-				dbus.Int32(g_tmo),
-				EOD))
-		self.assertTrue(tmp == '/')
-		vg_proxy.update()
-
-		self.assertTrue(
-			tag in vg_proxy.Vg.Tags,
-			"%s not in %s" % (tag, str(vg_proxy.Vg.Tags)))
+		self._tag_add_common(vg_proxy, tag)
 
 	def _verify_existence(self, cmd, operation, resource_name):
 		ec, stdout, stderr = call_lvm(cmd)


