From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 30 Jun 2022 16:00:53 +0000 (GMT)
Subject: main - lvmdbustest: Add test for property "Get"
Message-ID: <20220630160053.E866C386F0E1@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d0f94e763d6e6bca491c74cea93ec3062f32757e
Commit:        d0f94e763d6e6bca491c74cea93ec3062f32757e
Parent:        01ef2f2525e8733f01443987b2c6f99882e04f3d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 7 11:47:27 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 30 10:55:16 2022 -0500

lvmdbustest: Add test for property "Get"

We typically use "GetAll", so add test for "Get" and check values.
---
 test/dbus/lvmdbustest.py | 14 ++++++++++++++
 test/dbus/testlib.py     | 12 +++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 12f1741b1..e6f6d4891 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -677,6 +677,20 @@ class TestDbusService(unittest.TestCase):
 				EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
+	def test_prop_get(self):
+		lv_name = lv_n()
+		vg = self._vg_create().Vg
+		lv = self._test_lv_create(
+			vg.LvCreate,
+				(dbus.String(lv_name), dbus.UInt64(mib(4)),
+				dbus.Array([], signature='(ott)'), dbus.Int32(g_tmo),
+				EOD), vg, LV_BASE_INT)
+		ri = RemoteInterface(lv.dbus_object, interface=LV_COMMON_INT, introspect=False)
+
+		ri.update()
+		for prop_name in ri.get_property_names():
+			self.assertEqual(ri.get_property_value(prop_name), getattr(ri, prop_name))
+
 	def test_lv_create_job(self):
 		lv_name = lv_n()
 		vg = self._vg_create().Vg
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 75a367d40..b793b67a8 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -183,6 +183,7 @@ class RemoteInterface(object):
 					verify_type(
 						vl, self.introspect[self.interface]
 						['properties'][kl]['p_type'])
+				self.p_name[kl] = True
 				setattr(self, kl, vl)
 
 	@property
@@ -196,6 +197,7 @@ class RemoteInterface(object):
 		self.interface = interface
 		self.introspect = introspect
 		self.tmo = 0
+		self.p_name = {}
 
 		if timelimit >= 0:
 			self.tmo = float(timelimit)
@@ -213,7 +215,7 @@ class RemoteInterface(object):
 
 	def _wrapper(self, _method_name, *args, **kwargs):
 
-		# Lets see how long a method takes to execute, in call cases we should
+		# Let's see how long a method takes to execute, in call cases we should
 		# return something when the time limit has been reached.
 		start = time.time()
 		result = getattr(self.dbus_interface, _method_name)(*args, **kwargs)
@@ -241,6 +243,14 @@ class RemoteInterface(object):
 	def update(self):
 		self._set_props()
 
+	def get_property_names(self):
+		return self.p_name.keys()
+
+	def get_property_value(self, name):
+		prop_interface = dbus.Interface(
+			self.dbus_object, 'org.freedesktop.DBus.Properties')
+		return prop_interface.Get(self.interface, name)
+
 
 class ClientProxy(object):
 

