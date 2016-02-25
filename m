From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 25 Feb 2016 22:44:28 +0000 (UTC)
Subject: master - lvmdbustest.py: Move helper code to testlib.py
Message-ID: <20160225224428.E7C966109C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0d620e681fe42d0a1b2a5666677c36753838c6fd
Commit:        0d620e681fe42d0a1b2a5666677c36753838c6fd
Parent:        f1bc68beb4e493a9c1a52750e99d50f874ca89d9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Feb 25 16:11:08 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Feb 25 16:43:55 2016 -0600

lvmdbustest.py: Move helper code to testlib.py

This will allow us to re-use in other client programs for testing.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/dbus/lvmdbustest.py |  199 +++++-----------------------------------------
 test/dbus/testlib.py     |  174 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 195 insertions(+), 178 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 92f5d70..4c58552 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -14,35 +14,10 @@ import dbus
 from dbus.mainloop.glib import DBusGMainLoop
 import unittest
 import sys
-import random
-import string
-import functools
 import time
 import pyudev
 import os
-import xml.etree.ElementTree as Et
-from collections import OrderedDict
-
-BUSNAME = "com.redhat.lvmdbus1"
-MANAGER_INT = BUSNAME + '.Manager'
-MANAGER_OBJ = '/' + BUSNAME.replace('.', '/') + 'Manager'
-PV_INT = BUSNAME + ".Pv"
-VG_INT = BUSNAME + ".Vg"
-LV_INT = BUSNAME + ".Lv"
-THINPOOL_INT = BUSNAME + ".ThinPool"
-SNAPSHOT_INT = BUSNAME + ".Snapshot"
-LV_COMMON_INT = BUSNAME + ".LvCommon"
-JOB_INT = BUSNAME + ".Job"
-CACHE_POOL_INT = BUSNAME + ".CachePool"
-CACHE_LV_INT = BUSNAME + ".CachedLv"
-
-THINPOOL_LV_PATH = '/' + THINPOOL_INT.replace('.', '/')
-
-
-def rs(length, suffix, character_set=string.ascii_lowercase):
-	return ''.join(random.choice(character_set)
-				for _ in range(length)) + suffix
-
+from testlib import *
 
 use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
 
@@ -52,144 +27,6 @@ else:
 	bus = dbus.SystemBus(mainloop=DBusGMainLoop())
 
 
-def mib(s):
-	return 1024 * 1024 * s
-
-
-class DbusIntrospection(object):
-	@staticmethod
-	def introspect(xml_representation):
-		interfaces = {}
-
-		root = Et.fromstring(xml_representation)
-
-		for c in root:
-			if c.tag == "interface":
-				in_f = c.attrib['name']
-				interfaces[in_f] = \
-					dict(methods=OrderedDict(), properties={})
-				for nested in c:
-					if nested.tag == "method":
-						mn = nested.attrib['name']
-						interfaces[in_f]['methods'][mn] = OrderedDict()
-
-						for arg in nested:
-							if arg.tag == 'arg':
-								arg_dir = arg.attrib['direction']
-								if arg_dir == 'in':
-									n = arg.attrib['name']
-								else:
-									n = None
-
-								arg_type = arg.attrib['type']
-
-								if n:
-									v = dict(
-											name=mn,
-											a_dir=arg_dir,
-											a_type=arg_type)
-									interfaces[in_f]['methods'][mn][n] = v
-
-					elif nested.tag == 'property':
-						pn = nested.attrib['name']
-						p_access = nested.attrib['access']
-						p_type = nested.attrib['type']
-
-						interfaces[in_f]['properties'][pn] = \
-							dict(p_access=p_access, p_type=p_type)
-					else:
-						pass
-
-		# print('Interfaces...')
-		# for k, v in list(interfaces.items()):
-		#     print('Interface %s' % k)
-		#     if v['methods']:
-		#         for m, args in list(v['methods'].items()):
-		#             print('    method: %s' % m)
-		#             for a, aa in args.items():
-		#                 print('         method arg: %s' % (a))
-		#     if v['properties']:
-		#         for p, d in list(v['properties'].items()):
-		#             print('    Property: %s' % (p))
-		# print('End interfaces')
-
-		return interfaces
-
-
-class RemoteObject(object):
-	def _set_props(self, props=None):
-		# print 'Fetching properties'
-		if not props:
-			# prop_fetch = dbus.Interface(self.bus.get_object(
-			#    BUSNAME, self.object_path), 'org.freedesktop.DBus.Properties')
-
-			for i in range(0, 3):
-				try:
-					prop_fetch = dbus.Interface(self.bus.get_object(
-						BUSNAME, self.object_path),
-						'org.freedesktop.DBus.Properties')
-					props = prop_fetch.GetAll(self.interface)
-					break
-				except dbus.exceptions.DBusException as dbe:
-					if "GetAll" not in str(dbe):
-						raise dbe
-		if props:
-			for kl, vl in list(props.items()):
-				setattr(self, kl, vl)
-
-	def __init__(self, specified_bus, object_path, interface, properties=None):
-		self.object_path = object_path
-		self.interface = interface
-		self.bus = specified_bus
-
-		self.dbus_method = dbus.Interface(specified_bus.get_object(
-			BUSNAME, self.object_path), self.interface)
-
-		self._set_props(properties)
-
-	def __getattr__(self, item):
-		if hasattr(self.dbus_method, item):
-			return functools.partial(self._wrapper, item)
-		else:
-			return functools.partial(self, item)
-
-	def _wrapper(self, _method_name, *args, **kwargs):
-		return getattr(self.dbus_method, _method_name)(*args, **kwargs)
-
-	def update(self):
-		self._set_props()
-
-
-class ClientProxy(object):
-	@staticmethod
-	def _intf_short_name(nm):
-		return nm.split('.')[-1:][0]
-
-	def __init__(self, specified_bus, object_path, interface=None, props=None):
-		i = dbus.Interface(specified_bus.get_object(
-			BUSNAME, object_path), 'org.freedesktop.DBus.Introspectable')
-		self.intro_spect = DbusIntrospection.introspect(i.Introspect())
-
-		for k in self.intro_spect.keys():
-			sn = ClientProxy._intf_short_name(k)
-			# print('Client proxy has interface: %s %s' % (k, sn))
-
-			if interface and interface == k and props is not None:
-				ro = RemoteObject(specified_bus, object_path, k, props)
-			else:
-				ro = RemoteObject(specified_bus, object_path, k)
-
-			setattr(self, sn, ro)
-
-		self.object_path = object_path
-
-	def update(self):
-		# Go through all interfaces and update them
-		for int_f in self.intro_spect.keys():
-			sn = ClientProxy._intf_short_name(int_f)
-			getattr(self, sn).update()
-
-
 def get_objects():
 	rc = {MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
 			THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
@@ -692,11 +529,12 @@ class TestDbusService(unittest.TestCase):
 		vg = self._vg_create(pv_paths).Vg
 		lv = self._create_lv(vg=vg, size=mib(16))
 
-		for size in [
-					lv.LvCommon.SizeBytes + 4194304,
-					lv.LvCommon.SizeBytes - 4194304,
-					lv.LvCommon.SizeBytes + 2048,
-					lv.LvCommon.SizeBytes - 2048]:
+		for size in \
+			[
+			lv.LvCommon.SizeBytes + 4194304,
+			lv.LvCommon.SizeBytes - 4194304,
+			lv.LvCommon.SizeBytes + 2048,
+			lv.LvCommon.SizeBytes - 2048]:
 
 			pv_in_use = [i[0] for i in lv.LvCommon.Devices]
 			# Select a PV in the VG that isn't in use
@@ -1052,13 +890,16 @@ class TestDbusService(unittest.TestCase):
 
 		mgr = self._manager().Manager
 
-		self.assertEqual(mgr.PvScan(False, True,
-									dbus.Array([], 's'),
-									dbus.Array([], '(ii)'), -1, {}), '/')
+		self.assertEqual(
+			mgr.PvScan(
+				False, True, dbus.Array([], 's'),
+				dbus.Array([], '(ii)'), -1, {}), '/')
 		self.assertEqual(self._refresh(), 0)
-		self.assertEqual(mgr.PvScan(False, False,
-									dbus.Array([], 's'),
-									dbus.Array([], '(ii)'), -1, {}), '/')
+		self.assertEqual(
+			mgr.PvScan(
+				False, False,
+				dbus.Array([], 's'),
+				dbus.Array([], '(ii)'), -1, {}), '/')
 		self.assertEqual(self._refresh(), 0)
 
 		block_path = []
@@ -1081,9 +922,11 @@ class TestDbusService(unittest.TestCase):
 
 		self.assertEqual(self._refresh(), 0)
 
-		self.assertEqual(mgr.PvScan(False, True,
-									dbus.Array([], 's'),
-									mm, -1, {}), '/')
+		self.assertEqual(
+			mgr.PvScan(
+				False, True,
+				dbus.Array([], 's'),
+				mm, -1, {}), '/')
 
 		self.assertEqual(self._refresh(), 0)
 
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
new file mode 100644
index 0000000..550b0bf
--- /dev/null
+++ b/test/dbus/testlib.py
@@ -0,0 +1,174 @@
+#!/usr/bin/env python3
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+import string
+import random
+import functools
+import xml.etree.ElementTree as Et
+from collections import OrderedDict
+import dbus
+
+BUSNAME = "com.redhat.lvmdbus1"
+MANAGER_INT = BUSNAME + '.Manager'
+MANAGER_OBJ = '/' + BUSNAME.replace('.', '/') + '/Manager'
+PV_INT = BUSNAME + ".Pv"
+VG_INT = BUSNAME + ".Vg"
+LV_INT = BUSNAME + ".Lv"
+THINPOOL_INT = BUSNAME + ".ThinPool"
+SNAPSHOT_INT = BUSNAME + ".Snapshot"
+LV_COMMON_INT = BUSNAME + ".LvCommon"
+JOB_INT = BUSNAME + ".Job"
+CACHE_POOL_INT = BUSNAME + ".CachePool"
+CACHE_LV_INT = BUSNAME + ".CachedLv"
+
+THINPOOL_LV_PATH = '/' + THINPOOL_INT.replace('.', '/')
+
+
+def rs(length, suffix, character_set=string.ascii_lowercase):
+	return ''.join(random.choice(character_set)
+				for _ in range(length)) + suffix
+
+
+def mib(s):
+	return 1024 * 1024 * s
+
+
+class DbusIntrospection(object):
+	@staticmethod
+	def introspect(xml_representation):
+		interfaces = {}
+
+		root = Et.fromstring(xml_representation)
+
+		for c in root:
+			if c.tag == "interface":
+				in_f = c.attrib['name']
+				interfaces[in_f] = \
+					dict(methods=OrderedDict(), properties={})
+				for nested in c:
+					if nested.tag == "method":
+						mn = nested.attrib['name']
+						interfaces[in_f]['methods'][mn] = OrderedDict()
+
+						for arg in nested:
+							if arg.tag == 'arg':
+								arg_dir = arg.attrib['direction']
+								if arg_dir == 'in':
+									n = arg.attrib['name']
+								else:
+									n = None
+
+								arg_type = arg.attrib['type']
+
+								if n:
+									v = dict(
+											name=mn,
+											a_dir=arg_dir,
+											a_type=arg_type)
+									interfaces[in_f]['methods'][mn][n] = v
+
+					elif nested.tag == 'property':
+						pn = nested.attrib['name']
+						p_access = nested.attrib['access']
+						p_type = nested.attrib['type']
+
+						interfaces[in_f]['properties'][pn] = \
+							dict(p_access=p_access, p_type=p_type)
+					else:
+						pass
+
+		# print('Interfaces...')
+		# for k, v in list(interfaces.items()):
+		#     print('Interface %s' % k)
+		#     if v['methods']:
+		#         for m, args in list(v['methods'].items()):
+		#             print('    method: %s' % m)
+		#             for a, aa in args.items():
+		#                 print('         method arg: %s' % (a))
+		#     if v['properties']:
+		#         for p, d in list(v['properties'].items()):
+		#             print('    Property: %s' % (p))
+		# print('End interfaces')
+
+		return interfaces
+
+
+class RemoteObject(object):
+	def _set_props(self, props=None):
+		# print 'Fetching properties'
+		if not props:
+			# prop_fetch = dbus.Interface(self.bus.get_object(
+			#    BUSNAME, self.object_path), 'org.freedesktop.DBus.Properties')
+
+			for i in range(0, 3):
+				try:
+					prop_fetch = dbus.Interface(self.bus.get_object(
+						BUSNAME, self.object_path),
+						'org.freedesktop.DBus.Properties')
+					props = prop_fetch.GetAll(self.interface)
+					break
+				except dbus.exceptions.DBusException as dbe:
+					if "GetAll" not in str(dbe):
+						raise dbe
+		if props:
+			for kl, vl in list(props.items()):
+				setattr(self, kl, vl)
+
+	def __init__(self, specified_bus, object_path, interface, properties=None):
+		self.object_path = object_path
+		self.interface = interface
+		self.bus = specified_bus
+
+		self.dbus_method = dbus.Interface(specified_bus.get_object(
+			BUSNAME, self.object_path), self.interface)
+
+		self._set_props(properties)
+
+	def __getattr__(self, item):
+		if hasattr(self.dbus_method, item):
+			return functools.partial(self._wrapper, item)
+		else:
+			return functools.partial(self, item)
+
+	def _wrapper(self, _method_name, *args, **kwargs):
+		return getattr(self.dbus_method, _method_name)(*args, **kwargs)
+
+	def update(self):
+		self._set_props()
+
+
+class ClientProxy(object):
+	@staticmethod
+	def _intf_short_name(nm):
+		return nm.split('.')[-1:][0]
+
+	def __init__(self, specified_bus, object_path, interface=None, props=None):
+		i = dbus.Interface(specified_bus.get_object(
+			BUSNAME, object_path), 'org.freedesktop.DBus.Introspectable')
+		self.intro_spect = DbusIntrospection.introspect(i.Introspect())
+
+		for k in self.intro_spect.keys():
+			sn = ClientProxy._intf_short_name(k)
+			# print('Client proxy has interface: %s %s' % (k, sn))
+
+			if interface and interface == k and props is not None:
+				ro = RemoteObject(specified_bus, object_path, k, props)
+			else:
+				ro = RemoteObject(specified_bus, object_path, k)
+
+			setattr(self, sn, ro)
+
+		self.object_path = object_path
+
+	def update(self):
+		# Go through all interfaces and update them
+		for int_f in self.intro_spect.keys():
+			sn = ClientProxy._intf_short_name(int_f)
+			getattr(self, sn).update()


