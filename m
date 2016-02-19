From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 19 Feb 2016 21:17:20 +0000 (UTC)
Subject: master - lvmdbustest.py: resync latest changes
Message-ID: <20160219211720.F022561B4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b6cad32199dd08d8f56d5f0cec0f5e24928211c
Commit:        8b6cad32199dd08d8f56d5f0cec0f5e24928211c
Parent:        eefcbd5b28aae6c0bed22a6ff8cb97141184083f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Feb 19 15:16:05 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Feb 19 15:16:05 2016 -0600

lvmdbustest.py: resync latest changes

This file update was missed, copied latest file from:
https://github.com/tasleson/lvm-dubstep/blob/master/test/lvmdbustest.py

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 test/dbus/lvmdbustest.py | 1907 ++++++++++++++++++++++++++--------------------
 1 files changed, 1060 insertions(+), 847 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 7f3bcca..bdeb1a3 100644
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1,19 +1,13 @@
 #!/usr/bin/env python3
 
-# This program is free software; you can redistribute it and/or modify
-# it under the terms of the GNU General Public License as
-# published by the Free Software Foundation; either version 3 of the
-# License, or (at your option) any later version.
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
 #
-# This program is distributed in the hope that it will be useful,
-# but WITHOUT ANY WARRANTY; without even the implied warranty of
-# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-# GNU General Public License for more details.
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
-#
-# Copyright 2015, Tony Asleson <tasleson@redhat.com>
 
 import dbus
 # noinspection PyUnresolvedReferences
@@ -29,7 +23,6 @@ import os
 import xml.etree.ElementTree as Et
 from collections import OrderedDict
 
-
 BUSNAME = "com.redhat.lvmdbus1"
 MANAGER_INT = BUSNAME + '.Manager'
 MANAGER_OBJ = '/' + BUSNAME.replace('.', '/') + 'Manager'
@@ -46,1008 +39,1228 @@ CACHE_LV_INT = BUSNAME + ".CachedLv"
 THINPOOL_LV_PATH = '/' + THINPOOL_INT.replace('.', '/')
 
 
-def rs(length, suffix):
-    return ''.join(random.choice(string.ascii_lowercase)
-                   for _ in range(length)) + suffix
+def rs(length, suffix, character_set=string.ascii_lowercase):
+	return ''.join(random.choice(character_set)
+				for _ in range(length)) + suffix
+
 
 bus = dbus.SystemBus(mainloop=DBusGMainLoop())
 
 
 class DbusIntrospection(object):
-
-    @staticmethod
-    def introspect(xml_representation):
-        interfaces = {}
-
-        root = Et.fromstring(xml_representation)
-
-        for c in root:
-            if c.tag == "interface":
-                in_f = c.attrib['name']
-                interfaces[in_f] = \
-                    dict(methods=OrderedDict(), properties={})
-                for nested in c:
-                    if nested.tag == "method":
-                        mn = nested.attrib['name']
-                        interfaces[in_f]['methods'][mn] = OrderedDict()
-
-                        for arg in nested:
-                            if arg.tag == 'arg':
-                                arg_dir = arg.attrib['direction']
-                                if arg_dir == 'in':
-                                    n = arg.attrib['name']
-                                else:
-                                    n = None
-
-                                arg_type = arg.attrib['type']
-
-                                if n:
-                                    v = dict(name=mn,
-                                             a_dir=arg_dir,
-                                             a_type=arg_type)
-                                    interfaces[in_f]['methods'][mn][n] = v
-
-                    elif nested.tag == 'property':
-                        pn = nested.attrib['name']
-                        p_access = nested.attrib['access']
-                        p_type = nested.attrib['type']
-
-                        interfaces[in_f]['properties'][pn] = \
-                            dict(p_access=p_access, p_type=p_type)
-                    else:
-                        pass
-
-        # print('Interfaces...')
-        # for k, v in list(interfaces.items()):
-        #     print('Interface %s' % k)
-        #     if v['methods']:
-        #         for m, args in list(v['methods'].items()):
-        #             print('    method: %s' % m)
-        #             for a, aa in args.items():
-        #                 print('         method arg: %s' % (a))
-        #     if v['properties']:
-        #         for p, d in list(v['properties'].items()):
-        #             print('    Property: %s' % (p))
-        # print('End interfaces')
-
-        return interfaces
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
 
 
 class RemoteObject(object):
-
-    def _set_props(self, props=None):
-        #print 'Fetching properties'
-        if not props:
-            #prop_fetch = dbus.Interface(self.bus.get_object(
-            #    BUSNAME, self.object_path), 'org.freedesktop.DBus.Properties')
-
-            for i in range(0, 3):
-                try:
-                    prop_fetch = dbus.Interface(self.bus.get_object(
-                        BUSNAME, self.object_path),
-                        'org.freedesktop.DBus.Properties')
-                    props = prop_fetch.GetAll(self.interface)
-                    break
-                except dbus.exceptions.DBusException as dbe:
-                    if "GetAll" not in str(dbe):
-                        raise dbe
-        if props:
-            for kl, vl in list(props.items()):
-                setattr(self, kl, vl)
-
-    def __init__(self, specified_bus, object_path, interface, properties=None):
-        self.object_path = object_path
-        self.interface = interface
-        self.bus = specified_bus
-
-        self.dbus_method = dbus.Interface(specified_bus.get_object(
-            BUSNAME, self.object_path), self.interface)
-
-        self._set_props(properties)
-
-    def __getattr__(self, item):
-        if hasattr(self.dbus_method, item):
-            return functools.partial(self._wrapper, item)
-        else:
-            return functools.partial(self, item)
-
-    def _wrapper(self, _method_name, *args, **kwargs):
-        return getattr(self.dbus_method, _method_name)(*args, **kwargs)
-
-    def update(self):
-        self._set_props()
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
 
 
 class ClientProxy(object):
+	@staticmethod
+	def _intf_short_name(nm):
+		return nm.split('.')[-1:][0]
 
-    @staticmethod
-    def _intf_short_name(nm):
-        return nm.split('.')[-1:][0]
-
-    def __init__(self, specified_bus, object_path, interface=None, props=None):
-        i = dbus.Interface(specified_bus.get_object(
-            BUSNAME, object_path), 'org.freedesktop.DBus.Introspectable')
-        self.intro_spect = DbusIntrospection.introspect(i.Introspect())
+	def __init__(self, specified_bus, object_path, interface=None, props=None):
+		i = dbus.Interface(specified_bus.get_object(
+			BUSNAME, object_path), 'org.freedesktop.DBus.Introspectable')
+		self.intro_spect = DbusIntrospection.introspect(i.Introspect())
 
-        for k in self.intro_spect.keys():
-            sn = ClientProxy._intf_short_name(k)
-            #print('Client proxy has interface: %s %s' % (k, sn))
+		for k in self.intro_spect.keys():
+			sn = ClientProxy._intf_short_name(k)
+			# print('Client proxy has interface: %s %s' % (k, sn))
 
-            if interface and interface == k and props is not None:
-                ro = RemoteObject(specified_bus, object_path, k, props)
-            else:
-                ro = RemoteObject(specified_bus, object_path, k)
+			if interface and interface == k and props is not None:
+				ro = RemoteObject(specified_bus, object_path, k, props)
+			else:
+				ro = RemoteObject(specified_bus, object_path, k)
 
-            setattr(self, sn, ro)
+			setattr(self, sn, ro)
 
-        self.object_path = object_path
+		self.object_path = object_path
 
-    def update(self):
-        # Go through all interfaces and update them
-        for int_f in self.intro_spect.keys():
-            sn = ClientProxy._intf_short_name(int_f)
-            getattr(self, sn).update()
+	def update(self):
+		# Go through all interfaces and update them
+		for int_f in self.intro_spect.keys():
+			sn = ClientProxy._intf_short_name(int_f)
+			getattr(self, sn).update()
 
 
 def get_objects():
-    rc = {MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
-          THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
-          CACHE_POOL_INT: [], CACHE_LV_INT: []}
+	rc = {MANAGER_INT: [], PV_INT: [], VG_INT: [], LV_INT: [],
+			THINPOOL_INT: [], JOB_INT: [], SNAPSHOT_INT: [], LV_COMMON_INT: [],
+			CACHE_POOL_INT: [], CACHE_LV_INT: []}
 
-    manager = dbus.Interface(bus.get_object(
-        BUSNAME, "/com/redhat/lvmdbus1"),
-        "org.freedesktop.DBus.ObjectManager")
+	manager = dbus.Interface(bus.get_object(
+		BUSNAME, "/com/redhat/lvmdbus1"),
+		"org.freedesktop.DBus.ObjectManager")
 
-    objects = manager.GetManagedObjects()
+	objects = manager.GetManagedObjects()
 
-    for object_path, val in list(objects.items()):
-        for interface, props in list(val.items()):
-            o = ClientProxy(bus, object_path, interface, props)
-            rc[interface].append(o)
+	for object_path, val in list(objects.items()):
+		for interface, props in list(val.items()):
+			o = ClientProxy(bus, object_path, interface, props)
+			rc[interface].append(o)
 
-    return rc, bus
+	return rc, bus
 
 
 def set_execution(lvmshell):
-    lvm_manager = dbus.Interface(bus.get_object(
-        BUSNAME, "/com/redhat/lvmdbus1/Manager"),
-        "com.redhat.lvmdbus1.Manager")
-    lvm_manager.UseLvmShell(lvmshell)
+	lvm_manager = dbus.Interface(bus.get_object(
+		BUSNAME, "/com/redhat/lvmdbus1/Manager"),
+		"com.redhat.lvmdbus1.Manager")
+	lvm_manager.UseLvmShell(lvmshell)
 
 
 # noinspection PyUnresolvedReferences
 class TestDbusService(unittest.TestCase):
-    def setUp(self):
-        # Because of the sensitive nature of running LVM tests we will only
-        # run if we have PVs and nothing else, so that we can be confident that
-        # we are not mucking with someones data on their system
-        self.objs, self.bus = get_objects()
-        if len(self.objs[PV_INT]) == 0:
-            print('No PVs present exiting!')
-            sys.exit(1)
-        if len(self.objs[MANAGER_INT]) != 1:
-            print('Expecting a manager object!')
-            sys.exit(1)
-
-        if len(self.objs[VG_INT]) != 0:
-            print('Expecting no VGs to exist!')
-            sys.exit(1)
-
-        self.pvs = []
-        for p in self.objs[PV_INT]:
-            self.pvs.append(p.Pv.Name)
-
-    def tearDown(self):
-        # If we get here it means we passed setUp, so lets remove anything
-        # and everything that remains, besides the PVs themselves
-        self.objs, self.bus = get_objects()
-        for v in self.objs[VG_INT]:
-            #print "DEBUG: Removing VG= ", v.Uuid, v.Name
-            v.Vg.Remove(-1, {})
-
-        # Check to make sure the PVs we had to start exist, else re-create
-        # them
-        if len(self.pvs) != len(self.objs[PV_INT]):
-            for p in self.pvs:
-                found = False
-                for pc in self.objs[PV_INT]:
-                    if pc.Pv.Name == p:
-                        found = True
-                        break
-
-                if not found:
-                    # print('Re-creating PV=', p)
-                    self._pv_create(p)
-
-    def _pv_create(self, device):
-        pv_path = self.objs[MANAGER_INT][0].Manager.PvCreate(device, -1, {})[0]
-        self.assertTrue(pv_path is not None and len(pv_path) > 0)
-        return pv_path
-
-    def _manager(self):
-        return self.objs[MANAGER_INT][0]
-
-    def _refresh(self):
-        return self._manager().Manager.Refresh()
-
-    def test_refresh(self):
-        rc = self._refresh()
-        self.assertEqual(rc, 0)
-
-    def test_version(self):
-        rc = self.objs[MANAGER_INT][0].Manager.Version
-        self.assertTrue(rc is not None and len(rc) > 0)
-        self.assertEqual(self._refresh(), 0)
-
-    def _vg_create(self, pv_paths=None):
-
-        if not pv_paths:
-            pv_paths = [self.objs[PV_INT][0].object_path]
-
-        vg_name = rs(8, '_vg')
-
-        vg_path = self.objs[MANAGER_INT][0].Manager.VgCreate(
-            vg_name,
-            pv_paths,
-            -1,
-            {})[0]
-        self.assertTrue(vg_path is not None and len(vg_path) > 0)
-        return ClientProxy(self.bus, vg_path)
-
-    def test_vg_create(self):
-        self._vg_create()
-        self.assertEqual(self._refresh(), 0)
-
-    def test_vg_delete(self):
-        vg = self._vg_create().Vg
-        vg.Remove(-1, {})
-        self.assertEqual(self._refresh(), 0)
-
-    def _pv_remove(self, pv):
-        rc = pv.Pv.Remove(-1, {})
-        return rc
-
-    def test_pv_remove_add(self):
-        target = self.objs[PV_INT][0]
-
-        # Remove the PV
-        rc = self._pv_remove(target)
-        self.assertTrue(rc == '/')
-        self.assertEqual(self._refresh(), 0)
-
-        # Add it back
-        rc = self._pv_create(target.Pv.Name)[0]
-        self.assertTrue(rc == '/')
-        self.assertEqual(self._refresh(), 0)
-
-    def _lookup(self, lvm_id):
-        return self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lvm_id)
-
-    def test_lookup_by_lvm_id(self):
-        # For the moment lets just lookup what we know about which is PVs
-        # When we start testing VGs and LVs we will test lookups for those
-        # during those unit tests
-        for p in self.objs[PV_INT]:
-            rc = self._lookup(p.Pv.Name)
-            self.assertTrue(rc is not None and rc != '/')
-
-        # Search for something which doesn't exist
-        rc = self._lookup('/dev/null')
-        self.assertTrue(rc == '/')
-
-    def test_vg_extend(self):
-        # Create a VG
-        self.assertTrue(len(self.objs[PV_INT]) >= 2)
-
-        if len(self.objs[PV_INT]) >= 2:
-            pv_initial = self.objs[PV_INT][0]
-            pv_next = self.objs[PV_INT][1]
-
-            vg = self._vg_create([pv_initial.object_path]).Vg
-            path = vg.Extend([pv_next.object_path], -1, {})
-            self.assertTrue(path == '/')
-            self.assertEqual(self._refresh(), 0)
-
-    # noinspection PyUnresolvedReferences
-    def test_vg_reduce(self):
-        self.assertTrue(len(self.objs[PV_INT]) >= 2)
-
-        if len(self.objs[PV_INT]) >= 2:
-            vg = self._vg_create(
-                [self.objs[PV_INT][0].object_path,
-                 self.objs[PV_INT][1].object_path]).Vg
-
-            path = vg.Reduce(False, [vg.Pvs[0]], -1, {})
-            self.assertTrue(path == '/')
-            self.assertEqual(self._refresh(), 0)
-
-    # noinspection PyUnresolvedReferences
-    def test_vg_rename(self):
-        vg = self._vg_create().Vg
-
-        # Create some LVs in the VG
-        for i in range(0, 5):
-            self._create_lv(size=1024 * 1024 * 16, vg=vg)
-
-        path = vg.Rename('renamed_' + vg.Name, -1, {})
-        self.assertTrue(path == '/')
-        self.assertEqual(self._refresh(), 0)
-
-        # Go through each LV and make sure it has the correct path back to the
-        # VG
-        vg.update()
-
-        lv_paths = vg.Lvs
-        self.assertTrue(len(lv_paths) == 5)
-
-        for l in lv_paths:
-            lv_proxy = ClientProxy(self.bus, l).LvCommon
-            self.assertTrue(lv_proxy.Vg == vg.object_path, "%s != %s" %
-                            (lv_proxy.Vg, vg.object_path))
-
-    def _test_lv_create(self, method, params, vg):
-        lv = None
-        path = method(*params)[0]
-
-        self.assertTrue(vg)
-
-        if path:
-            lv = ClientProxy(self.bus, path)
-            # TODO verify object properties
-
-        self.assertEqual(self._refresh(), 0)
-        return lv
-
-    def test_lv_create(self):
-        vg = self._vg_create().Vg
-        self._test_lv_create(vg.LvCreate,
-                             (rs(8, '_lv'), 1024 * 1024 * 4,
-                              dbus.Array([], '(ott)'), -1, {}),
-                             vg)
-
-    def test_lv_create_linear(self):
-
-        vg = self._vg_create().Vg
-        self._test_lv_create(vg.LvCreateLinear,
-                             (rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
-                             vg)
-
-    def test_lv_create_striped(self):
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
-
-        vg = self._vg_create(pv_paths).Vg
-        self._test_lv_create(vg.LvCreateStriped,
-                             (rs(8, '_lv'), 1024 * 1024 * 4, 2, 8, False,
-                              -1, {}), vg)
-
-    def test_lv_create_mirror(self):
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
-
-        vg = self._vg_create(pv_paths).Vg
-        self._test_lv_create(vg.LvCreateMirror,
-                             (rs(8, '_lv'), 1024 * 1024 * 4, 2, -1, {}), vg)
-
-    def test_lv_create_raid(self):
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
-
-        vg = self._vg_create(pv_paths).Vg
-        self._test_lv_create(vg.LvCreateRaid,
-                             (rs(8, '_lv'), 'raid4',
-                              1024 * 1024 * 16, 2, 8, -1, {}), vg)
-
-    def _create_lv(self, thinpool=False, size=None, vg=None):
-
-        if not vg:
-            pv_paths = []
-            for pp in self.objs[PV_INT]:
-                pv_paths.append(pp.object_path)
-
-            vg = self._vg_create(pv_paths).Vg
-
-        if size is None:
-            size = 1024 * 1024 * 128
-
-        return self._test_lv_create(
-            vg.LvCreateLinear,
-            (rs(8, '_lv'), size, thinpool, -1, {}), vg)
+	def setUp(self):
+		# Because of the sensitive nature of running LVM tests we will only
+		# run if we have PVs and nothing else, so that we can be confident that
+		# we are not mucking with someones data on their system
+		self.objs, self.bus = get_objects()
+		if len(self.objs[PV_INT]) == 0:
+			print('No PVs present exiting!')
+			sys.exit(1)
+		if len(self.objs[MANAGER_INT]) != 1:
+			print('Expecting a manager object!')
+			sys.exit(1)
+
+		if len(self.objs[VG_INT]) != 0:
+			print('Expecting no VGs to exist!')
+			sys.exit(1)
+
+		self.pvs = []
+		for p in self.objs[PV_INT]:
+			self.pvs.append(p.Pv.Name)
+
+	def tearDown(self):
+		# If we get here it means we passed setUp, so lets remove anything
+		# and everything that remains, besides the PVs themselves
+		self.objs, self.bus = get_objects()
+		for v in self.objs[VG_INT]:
+			# print "DEBUG: Removing VG= ", v.Uuid, v.Name
+			v.Vg.Remove(-1, {})
+
+		# Check to make sure the PVs we had to start exist, else re-create
+		# them
+		if len(self.pvs) != len(self.objs[PV_INT]):
+			for p in self.pvs:
+				found = False
+				for pc in self.objs[PV_INT]:
+					if pc.Pv.Name == p:
+						found = True
+						break
+
+				if not found:
+					# print('Re-creating PV=', p)
+					self._pv_create(p)
+
+	def _pv_create(self, device):
+		pv_path = self.objs[MANAGER_INT][0].Manager.PvCreate(device, -1, {})[0]
+		self.assertTrue(pv_path is not None and len(pv_path) > 0)
+		return pv_path
+
+	def _manager(self):
+		return self.objs[MANAGER_INT][0]
+
+	def _refresh(self):
+		return self._manager().Manager.Refresh()
+
+	def test_refresh(self):
+		rc = self._refresh()
+		self.assertEqual(rc, 0)
+
+	def test_version(self):
+		rc = self.objs[MANAGER_INT][0].Manager.Version
+		self.assertTrue(rc is not None and len(rc) > 0)
+		self.assertEqual(self._refresh(), 0)
+
+	def _vg_create(self, pv_paths=None):
+
+		if not pv_paths:
+			pv_paths = [self.objs[PV_INT][0].object_path]
+
+		vg_name = rs(8, '_vg')
+
+		vg_path = self.objs[MANAGER_INT][0].Manager.VgCreate(
+			vg_name,
+			pv_paths,
+			-1,
+			{})[0]
+		self.assertTrue(vg_path is not None and len(vg_path) > 0)
+		return ClientProxy(self.bus, vg_path)
+
+	def test_vg_create(self):
+		self._vg_create()
+		self.assertEqual(self._refresh(), 0)
+
+	def test_vg_delete(self):
+		vg = self._vg_create().Vg
+		vg.Remove(-1, {})
+		self.assertEqual(self._refresh(), 0)
+
+	def _pv_remove(self, pv):
+		rc = pv.Pv.Remove(-1, {})
+		return rc
+
+	def test_pv_remove_add(self):
+		target = self.objs[PV_INT][0]
+
+		# Remove the PV
+		rc = self._pv_remove(target)
+		self.assertTrue(rc == '/')
+		self.assertEqual(self._refresh(), 0)
+
+		# Add it back
+		rc = self._pv_create(target.Pv.Name)[0]
+		self.assertTrue(rc == '/')
+		self.assertEqual(self._refresh(), 0)
+
+	def _lookup(self, lvm_id):
+		return self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lvm_id)
+
+	def test_lookup_by_lvm_id(self):
+		# For the moment lets just lookup what we know about which is PVs
+		# When we start testing VGs and LVs we will test lookups for those
+		# during those unit tests
+		for p in self.objs[PV_INT]:
+			rc = self._lookup(p.Pv.Name)
+			self.assertTrue(rc is not None and rc != '/')
+
+		# Search for something which doesn't exist
+		rc = self._lookup('/dev/null')
+		self.assertTrue(rc == '/')
+
+	def test_vg_extend(self):
+		# Create a VG
+		self.assertTrue(len(self.objs[PV_INT]) >= 2)
+
+		if len(self.objs[PV_INT]) >= 2:
+			pv_initial = self.objs[PV_INT][0]
+			pv_next = self.objs[PV_INT][1]
+
+			vg = self._vg_create([pv_initial.object_path]).Vg
+			path = vg.Extend([pv_next.object_path], -1, {})
+			self.assertTrue(path == '/')
+			self.assertEqual(self._refresh(), 0)
+
+	# noinspection PyUnresolvedReferences
+	def test_vg_reduce(self):
+		self.assertTrue(len(self.objs[PV_INT]) >= 2)
+
+		if len(self.objs[PV_INT]) >= 2:
+			vg = self._vg_create(
+				[self.objs[PV_INT][0].object_path,
+				self.objs[PV_INT][1].object_path]).Vg
+
+			path = vg.Reduce(False, [vg.Pvs[0]], -1, {})
+			self.assertTrue(path == '/')
+			self.assertEqual(self._refresh(), 0)
+
+	# noinspection PyUnresolvedReferences
+	def test_vg_rename(self):
+		vg = self._vg_create().Vg
+
+		mgr = self.objs[MANAGER_INT][0].Manager
+
+		# Do a vg lookup
+		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(vg.Name)
+
+		vg_name_start = vg.Name
+		prev_path = path
+		self.assertTrue(path != '/', "%s" % (path))
+
+		# Create some LVs in the VG
+		for i in range(0, 5):
+			lv_t = self._create_lv(size=1024 * 1024 * 16, vg=vg)
+			full_name = "%s/%s" % (vg_name_start, lv_t.LvCommon.Name)
+			lv_path = mgr.LookUpByLvmId(full_name)
+			self.assertTrue(lv_path == lv_t.object_path)
+
+		new_name = 'renamed_' + vg.Name
+
+		path = vg.Rename(new_name, -1, {})
+		self.assertTrue(path == '/')
+		self.assertEqual(self._refresh(), 0)
+
+		# Do a vg lookup
+		path = mgr.LookUpByLvmId(new_name)
+		self.assertTrue(path != '/', "%s" % (path))
+		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))
+
+		# Go through each LV and make sure it has the correct path back to the
+		# VG
+		vg.update()
+
+		lv_paths = vg.Lvs
+		self.assertTrue(len(lv_paths) == 5)
+
+		for l in lv_paths:
+			lv_proxy = ClientProxy(self.bus, l).LvCommon
+			self.assertTrue(lv_proxy.Vg == vg.object_path, "%s != %s" %
+							(lv_proxy.Vg, vg.object_path))
+			full_name = "%s/%s" % (new_name, lv_proxy.Name)
+			lv_path = mgr.LookUpByLvmId(full_name)
+			self.assertTrue(lv_path == lv_proxy.object_path, "%s != %s" %
+							(lv_path, lv_proxy.object_path))
+
+	def _verify_hidden_lookups(self, lv_common_object, vgname):
+		mgr = self.objs[MANAGER_INT][0].Manager
+
+		hidden_lv_paths = lv_common_object.HiddenLvs
+
+		for h in hidden_lv_paths:
+			h_lv = ClientProxy(self.bus, h).LvCommon
+
+			if len(h_lv.HiddenLvs) > 0:
+				self._verify_hidden_lookups(h_lv, vgname)
+
+			# print("Hidden check %s %s" % (h, h_lv.Name))
+			full_name = "%s/%s" % (vgname, h_lv.Name)
+			lookup_path = mgr.LookUpByLvmId(full_name)
+			self.assertTrue(lookup_path != '/')
+			self.assertTrue(lookup_path == h_lv.object_path)
+
+	def test_vg_rename_with_thin_pool(self):
+
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
+
+		vg = self._vg_create(pv_paths).Vg
+
+		vg_name_start = vg.Name
+
+		mgr = self.objs[MANAGER_INT][0].Manager
+
+		# Let's create a thin pool which uses a raid 5 meta and raid5 data
+		# areas
+		lv_meta_path = vg.LvCreateRaid(
+			"meta_r5", "raid5", 1024 * 1024 * 16, 0, 0, -1, {})[0]
+
+		lv_data_path = vg.LvCreateRaid(
+			"data_r5", "raid5", 1024 * 1024 * 512, 0, 0, -1, {})[0]
+
+		thin_pool_path = vg.CreateThinPool(
+			lv_meta_path, lv_data_path, -1, {})[0]
+
+		# Lets create some thin LVs
+		thin_pool = ClientProxy(self.bus, thin_pool_path)
+
+		# noinspection PyTypeChecker
+		self._verify_hidden_lookups(thin_pool.LvCommon, vg_name_start)
+
+		for i in range(0, 5):
+			lv_name = rs(8, '_lv')
+
+			thin_lv_path = thin_pool.ThinPool.LvCreate(
+				lv_name, 1024 * 1024 * 16, -1, {})[0]
+
+			self.assertTrue(thin_lv_path != '/')
+
+			full_name = "%s/%s" % (vg_name_start, lv_name)
+
+			lookup_lv_path = mgr.LookUpByLvmId(full_name)
+			self.assertTrue(thin_lv_path == lookup_lv_path,
+							"%s != %s" % (thin_lv_path, lookup_lv_path))
+
+		# Rename the VG
+		new_name = 'renamed_' + vg.Name
+
+		path = vg.Rename(new_name, -1, {})
+		self.assertTrue(path == '/')
+		self.assertEqual(self._refresh(), 0)
+
+		# Go through each LV and make sure it has the correct path back to the
+		# VG
+		vg.update()
+		thin_pool.update()
+
+		lv_paths = vg.Lvs
+
+		for l in lv_paths:
+			lv_proxy = ClientProxy(self.bus, l).LvCommon
+			self.assertTrue(lv_proxy.Vg == vg.object_path, "%s != %s" %
+							(lv_proxy.Vg, vg.object_path))
+			full_name = "%s/%s" % (new_name, lv_proxy.Name)
+			# print('Full Name %s' % (full_name))
+			lv_path = mgr.LookUpByLvmId(full_name)
+			self.assertTrue(lv_path == lv_proxy.object_path, "%s != %s" %
+							(lv_path, lv_proxy.object_path))
+
+		# noinspection PyTypeChecker
+		self._verify_hidden_lookups(thin_pool.LvCommon, new_name)
+
+	def _test_lv_create(self, method, params, vg):
+		lv = None
+		path = method(*params)[0]
+
+		self.assertTrue(vg)
+
+		if path:
+			lv = ClientProxy(self.bus, path)
+			# TODO verify object properties
+
+		self.assertEqual(self._refresh(), 0)
+		return lv
+
+	def test_lv_create(self):
+		vg = self._vg_create().Vg
+		self._test_lv_create(
+			vg.LvCreate,
+			(rs(8, '_lv'), 1024 * 1024 * 4,
+			dbus.Array([], '(ott)'), -1, {}), vg)
+
+	def test_lv_create_linear(self):
+
+		vg = self._vg_create().Vg
+		self._test_lv_create(
+			vg.LvCreateLinear,
+			(rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}), vg)
+
+	def test_lv_create_striped(self):
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
+
+		vg = self._vg_create(pv_paths).Vg
+		self._test_lv_create(
+			vg.LvCreateStriped,
+			(rs(8, '_lv'), 1024 * 1024 * 4, 2, 8, False,
+			-1, {}), vg)
+
+	def test_lv_create_mirror(self):
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
+
+		vg = self._vg_create(pv_paths).Vg
+		self._test_lv_create(vg.LvCreateMirror,
+			(rs(8, '_lv'), 1024 * 1024 * 4, 2, -1, {}), vg)
+
+	def test_lv_create_raid(self):
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
+
+		vg = self._vg_create(pv_paths).Vg
+		self._test_lv_create(vg.LvCreateRaid,
+			(rs(8, '_lv'), 'raid4',
+			1024 * 1024 * 16, 2, 8, -1, {}), vg)
+
+	def _create_lv(self, thinpool=False, size=None, vg=None):
+
+		if not vg:
+			pv_paths = []
+			for pp in self.objs[PV_INT]:
+				pv_paths.append(pp.object_path)
+
+			vg = self._vg_create(pv_paths).Vg
+
+		if size is None:
+			size = 1024 * 1024 * 128
+
+		return self._test_lv_create(
+			vg.LvCreateLinear,
+			(rs(8, '_lv'), size, thinpool, -1, {}), vg)
+
+	def test_lv_create_rounding(self):
+		self._create_lv(size=1024 * 1024 * 2 + 13)
+
+	def test_lv_create_thin_pool(self):
+		self._create_lv(True)
+
+	def test_lv_rename(self):
+		# Rename a regular LV
+		lv = self._create_lv()
+
+		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(lv.LvCommon.Name)
+		prev_path = path
+
+		new_name = 'renamed_' + lv.LvCommon.Name
+		lv.Lv.Rename(new_name, -1, {})
+
+		path = self.objs[MANAGER_INT][0].Manager.LookUpByLvmId(new_name)
+
+		self.assertEqual(self._refresh(), 0)
+		self.assertTrue(prev_path == path, "%s != %s" % (prev_path, path))
+
+	def test_lv_thinpool_rename(self):
+		# Rename a thin pool
+		tp = self._create_lv(True)
+		self.assertTrue(THINPOOL_LV_PATH in tp.object_path,
+						"%s" % (tp.object_path))
+
+		new_name = 'renamed_' + tp.LvCommon.Name
+		tp.Lv.Rename(new_name, -1, {})
+		tp.update()
+		self.assertEqual(self._refresh(), 0)
+		self.assertEqual(new_name, tp.LvCommon.Name)
+
+	# noinspection PyUnresolvedReferences
+	def test_lv_on_thin_pool_rename(self):
+		# Rename a LV on a thin Pool
+
+		# This returns a LV with the LV interface, need to get a proxy for
+		# thinpool interface too
+		tp = self._create_lv(True)
+
+		thin_path = tp.ThinPool.LvCreate(
+			rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
+
+		lv = ClientProxy(self.bus, thin_path)
+		rc = lv.Lv.Rename('rename_test' + lv.LvCommon.Name, -1, {})
+		self.assertTrue(rc == '/')
+		self.assertEqual(self._refresh(), 0)
+
+	def test_lv_remove(self):
+		lv = self._create_lv().Lv
+		rc = lv.Remove(-1, {})
+		self.assertTrue(rc == '/')
+		self.assertEqual(self._refresh(), 0)
+
+	def test_lv_snapshot(self):
+		lv_p = self._create_lv()
+		ss_name = 'ss_' + lv_p.LvCommon.Name
+
+		# Test waiting to complete
+		ss, job = lv_p.Lv.Snapshot(ss_name, 0, -1, {})
+		self.assertTrue(ss != '/')
+		self.assertTrue(job == '/')
+
+		snapshot = ClientProxy(self.bus, ss)
+		self.assertTrue(snapshot.LvCommon.Name == ss_name)
+
+		self.assertEqual(self._refresh(), 0)
+
+		# Test getting a job returned immediately
+		rc, job = lv_p.Lv.Snapshot('ss2_' + lv_p.LvCommon.Name, 0, 0, {})
+		self.assertTrue(rc == '/')
+		self.assertTrue(job != '/')
+		self._wait_for_job(job)
+
+		self.assertEqual(self._refresh(), 0)
+
+	# noinspection PyUnresolvedReferences
+	def _wait_for_job(self, j_path):
+		import time
+		rc = None
+		j = ClientProxy(self.bus, j_path).Job
+
+		while True:
+			j.update()
+			if j.Complete:
+				(ec, error_msg) = j.GetError
+				self.assertTrue(ec == 0, "%d :%s" % (ec, error_msg))
+
+				if ec == 0:
+					self.assertTrue(j.Percent == 100, "P= %f" % j.Percent)
+
+				rc = j.Result
+				j.Remove()
+
+				break
+
+			if j.Wait(1):
+				j.update()
+				self.assertTrue(j.Complete)
+
+		return rc
+
+	def test_lv_create_pv_specific(self):
+		vg = self._vg_create().Vg
+
+		pv = vg.Pvs
+
+		self._test_lv_create(vg.LvCreate,
+				(rs(8, '_lv'), 1024 * 1024 * 4,
+				dbus.Array([[pv[0], 0, 100]], '(ott)'), -1, {}), vg)
+
+	def test_lv_resize(self):
 
-    def test_lv_create_rounding(self):
-        self._create_lv(size=1024 * 1024 * 2 + 13)
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
 
-    def test_lv_create_thin_pool(self):
-        self._create_lv(True)
+		vg = self._vg_create(pv_paths).Vg
+		lv = self._create_lv(vg=vg)
 
-    def test_lv_rename(self):
-        # Rename a regular LV
-        lv = self._create_lv()
-        lv.Lv.Rename('renamed_' + lv.LvCommon.Name, -1, {})
-        self.assertEqual(self._refresh(), 0)
+		for size in [
+					lv.LvCommon.SizeBytes + 4194304,
+					lv.LvCommon.SizeBytes - 4194304,
+					lv.LvCommon.SizeBytes + 2048,
+					lv.LvCommon.SizeBytes - 2048]:
 
-    def test_lv_thinpool_rename(self):
-        # Rename a thin pool
-        tp = self._create_lv(True)
-        self.assertTrue(THINPOOL_LV_PATH in tp.object_path,
-                        "%s" % (tp.object_path))
+			pv_in_use = [i[0] for i in lv.LvCommon.Devices]
+			# Select a PV in the VG that isn't in use
+			pv_empty = [p for p in vg.Pvs if p not in pv_in_use]
 
-        new_name = 'renamed_' + tp.LvCommon.Name
-        tp.Lv.Rename(new_name, -1, {})
-        tp.update()
-        self.assertEqual(self._refresh(), 0)
-        self.assertEqual(new_name, tp.LvCommon.Name)
+			prev = lv.LvCommon.SizeBytes
 
-    # noinspection PyUnresolvedReferences
-    def test_lv_on_thin_pool_rename(self):
-        # Rename a LV on a thin Pool
+			if len(pv_empty):
+				rc = lv.Lv.Resize(
+					size, dbus.Array([[pv_empty[0], 0, 100]], '(oii)'),
+					-1, {})
+			else:
+				rc = lv.Lv.Resize(size, dbus.Array([], '(oii)'), -1, {})
 
-        # This returns a LV with the LV interface, need to get a proxy for
-        # thinpool interface too
-        tp = self._create_lv(True)
+			self.assertEqual(rc, '/')
+			self.assertEqual(self._refresh(), 0)
 
-        thin_path = tp.ThinPool.LvCreate(
-            rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
+			lv.update()
 
-        lv = ClientProxy(self.bus, thin_path)
-        rc = lv.Lv.Rename('rename_test' + lv.LvCommon.Name, -1, {})
-        self.assertTrue(rc == '/')
-        self.assertEqual(self._refresh(), 0)
+			if prev < size:
+				self.assertTrue(lv.LvCommon.SizeBytes > prev)
+			else:
+				# We are testing re-sizing to same size too...
+				self.assertTrue(lv.LvCommon.SizeBytes <= prev)
 
-    def test_lv_remove(self):
-        lv = self._create_lv().Lv
-        rc = lv.Remove(-1, {})
-        self.assertTrue(rc == '/')
-        self.assertEqual(self._refresh(), 0)
+	def test_lv_resize_same(self):
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
 
-    def test_lv_snapshot(self):
-        lv_p = self._create_lv()
-        ss_name = 'ss_' + lv_p.LvCommon.Name
+		vg = self._vg_create(pv_paths).Vg
+		lv = self._create_lv(vg=vg)
 
-        # Test waiting to complete
-        ss, job = lv_p.Lv.Snapshot(ss_name, 0, -1, {})
-        self.assertTrue(ss != '/')
-        self.assertTrue(job == '/')
+		with self.assertRaises(dbus.exceptions.DBusException):
+			lv.Lv.Resize(lv.LvCommon.SizeBytes, dbus.Array([], '(oii)'), -1, {})
 
-        snapshot = ClientProxy(self.bus, ss)
-        self.assertTrue(snapshot.LvCommon.Name == ss_name)
+	def test_lv_move(self):
+		lv = self._create_lv()
 
-        self.assertEqual(self._refresh(), 0)
+		pv_path_move = str(lv.LvCommon.Devices[0][0])
 
-        # Test getting a job returned immediately
-        rc, job = lv_p.Lv.Snapshot('ss2_' + lv_p.LvCommon.Name, 0, 0, {})
-        self.assertTrue(rc == '/')
-        self.assertTrue(job != '/')
-        self._wait_for_job(job)
+		# Test moving a specific LV
+		job = lv.Lv.Move(pv_path_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
+		self._wait_for_job(job)
+		self.assertEqual(self._refresh(), 0)
 
-        self.assertEqual(self._refresh(), 0)
+		lv.update()
+		new_pv = str(lv.LvCommon.Devices[0][0])
+		self.assertTrue(pv_path_move != new_pv, "%s == %s" %
+						(pv_path_move, new_pv))
 
-    # noinspection PyUnresolvedReferences
-    def _wait_for_job(self, j_path):
-        import time
-        rc = None
-        j = ClientProxy(self.bus, j_path).Job
+	def test_lv_activate_deactivate(self):
+		lv_p = self._create_lv()
+		lv_p.update()
 
-        while True:
-            j.update()
-            if j.Complete:
-                (ec, error_msg) = j.GetError
-                self.assertTrue(ec == 0, "%d :%s" % (ec, error_msg))
+		lv_p.Lv.Deactivate(0, -1, {})
+		lv_p.update()
+		self.assertFalse(lv_p.LvCommon.Active)
+		self.assertEqual(self._refresh(), 0)
 
-                if ec == 0:
-                    self.assertTrue(j.Percent == 100, "P= %f" % j.Percent)
+		lv_p.Lv.Activate(0, -1, {})
 
-                rc = j.Result
-                j.Remove()
+		lv_p.update()
+		self.assertTrue(lv_p.LvCommon.Active)
+		self.assertEqual(self._refresh(), 0)
 
-                break
+		# Try control flags
+		for i in range(0, 5):
+			lv_p.Lv.Activate(1 << i, -1, {})
+			self.assertTrue(lv_p.LvCommon.Active)
+			self.assertEqual(self._refresh(), 0)
 
-            if j.Wait(1):
-                j.update()
-                self.assertTrue(j.Complete)
+	def test_move(self):
+		lv = self._create_lv()
 
-        return rc
+		# Test moving without being LV specific
+		vg = ClientProxy(self.bus, lv.LvCommon.Vg).Vg
+		pv_to_move = str(lv.LvCommon.Devices[0][0])
+		job = vg.Move(pv_to_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
+		self._wait_for_job(job)
+		self.assertEqual(self._refresh(), 0)
 
-    def test_lv_create_pv_specific(self):
-        vg = self._vg_create().Vg
+		# Test Vg.Move
+		# TODO Test this more!
+		vg.update()
+		lv.update()
 
-        pv = vg.Pvs
+		location = lv.LvCommon.Devices[0][0]
 
-        self._test_lv_create(vg.LvCreate,
-                             (rs(8, '_lv'), 1024 * 1024 * 4,
-                              dbus.Array([[pv[0], 0, 100]], '(ott)'), -1, {}),
-                             vg)
+		dst = None
+		for p in vg.Pvs:
+			if p != location:
+				dst = p
 
-    def test_lv_resize(self):
+		# Fetch the destination
+		pv = ClientProxy(self.bus, dst).Pv
 
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
-
-        vg = self._vg_create(pv_paths).Vg
-        lv = self._create_lv(vg=vg)
-
-        for size in [lv.LvCommon.SizeBytes + 4194304,
-                     lv.LvCommon.SizeBytes - 4194304,
-                     lv.LvCommon.SizeBytes + 2048,
-                     lv.LvCommon.SizeBytes - 2048,
-                     lv.LvCommon.SizeBytes]:
+		# Test range, move it to the middle of the new destination and blocking
+		# blocking for it to complete
+		job = vg.Move(
+			location, (0, 0), [(dst, pv.PeCount / 2, 0), ], -1, {})
+		self.assertEqual(job, '/')
+		self.assertEqual(self._refresh(), 0)
 
-            pv_in_use = [i[0] for i in lv.LvCommon.Devices]
-            # Select a PV in the VG that isn't in use
-            pv_empty = [p for p in vg.Pvs if p not in pv_in_use]
+	def test_job_handling(self):
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
 
-            prev = lv.LvCommon.SizeBytes
+		vg_name = rs(8, '_vg')
 
-            if len(pv_empty):
-                rc = lv.Lv.Resize(size,
-                                  dbus.Array([[pv_empty[0], 0, 100]], '(oii)'),
-                                  -1, {})
-            else:
-                rc = lv.Lv.Resize(size, dbus.Array([], '(oii)'), -1, {})
+		# Test getting a job right away
+		vg_path, vg_job = self.objs[MANAGER_INT][0].Manager.VgCreate(
+			vg_name, pv_paths,
+			0, {})
 
-            self.assertEqual(rc, '/')
-            self.assertEqual(self._refresh(), 0)
+		self.assertTrue(vg_path == '/')
+		self.assertTrue(vg_job and len(vg_job) > 0)
 
-            lv.update()
+		self._wait_for_job(vg_job)
 
-            if prev < size:
-                self.assertTrue(lv.LvCommon.SizeBytes > prev)
-            else:
-                # We are testing re-sizing to same size too...
-                self.assertTrue(lv.LvCommon.SizeBytes <= prev)
+	def _test_expired_timer(self, num_lvs):
+		rc = False
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
 
-    def test_lv_move(self):
-        lv = self._create_lv()
+		# In small configurations lvm is pretty snappy, so lets create a VG
+		# add a number of LVs and then remove the VG and all the contained
+		# LVs which appears to consistently run a little slow.
 
-        pv_path_move = str(lv.LvCommon.Devices[0][0])
+		vg = self._vg_create(pv_paths).Vg
 
-        # Test moving a specific LV
-        job = lv.Lv.Move(pv_path_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
-        self._wait_for_job(job)
-        self.assertEqual(self._refresh(), 0)
+		for i in range(0, num_lvs):
+			obj_path, job = vg.LvCreateLinear(
+				rs(8, "_lv"), 1024 * 1024 * 4, False, -1, {})
+			self.assertTrue(job == '/')
 
-        lv.update()
-        new_pv = str(lv.LvCommon.Devices[0][0])
-        self.assertTrue(pv_path_move != new_pv, "%s == %s" %
-                        (pv_path_move, new_pv))
+		# Make sure that we are honoring the timeout
+		start = time.time()
 
-    def test_lv_activate_deactivate(self):
-        lv_p = self._create_lv()
-        lv_p.update()
+		remove_job = vg.Remove(1, {})
 
-        lv_p.Lv.Deactivate(0, -1, {})
-        lv_p.update()
-        self.assertFalse(lv_p.LvCommon.Active)
-        self.assertEqual(self._refresh(), 0)
+		end = time.time()
 
-        lv_p.Lv.Activate(0, -1, {})
+		tt_remove = float(end) - float(start)
 
-        lv_p.update()
-        self.assertTrue(lv_p.LvCommon.Active)
-        self.assertEqual(self._refresh(), 0)
+		self.assertTrue(tt_remove < 2.0, "remove time %s" % (str(tt_remove)))
 
-        # Try control flags
-        for i in range(0, 5):
-            lv_p.Lv.Activate(1 << i, -1, {})
-            self.assertTrue(lv_p.LvCommon.Active)
-            self.assertEqual(self._refresh(), 0)
+		# Depending on how long it took we could finish either way
+		if remove_job != '/':
+			# We got a job
+			result = self._wait_for_job(remove_job)
+			self.assertTrue(result == '/')
+			rc = True
+		else:
+			# It completed before timer popped
+			pass
 
-    def test_move(self):
-        lv = self._create_lv()
+		return rc
+
+	def test_job_handling_timer(self):
+
+		yes = False
+
+		# This may not pass
+		for i in [48, 64, 128]:
+			yes = self._test_expired_timer(i)
+			if yes:
+				break
+			print('Attempt (%d) failed, trying again...' % (i))
+
+		self.assertTrue(yes)
+
+	def test_pv_tags(self):
+		pvs = []
+
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
+
+		vg = self._vg_create(pv_paths).Vg
+
+		# Get the PVs
+		for p in vg.Pvs:
+			pvs.append(ClientProxy(self.bus, p).Pv)
+
+		for tags_value in [['hello'], ['foo', 'bar']]:
+			rc = vg.PvTagsAdd(vg.Pvs, tags_value, -1, {})
+			self.assertTrue(rc == '/')
+
+			for p in pvs:
+				p.update()
+				self.assertTrue(sorted(tags_value) == p.Tags)
+
+			vg.PvTagsDel(vg.Pvs, tags_value, -1, {})
+			for p in pvs:
+				p.update()
+				self.assertTrue([] == p.Tags)
+
+	def test_vg_tags(self):
+		vg = self._vg_create().Vg
 
-        # Test moving without being LV specific
-        vg = ClientProxy(self.bus, lv.LvCommon.Vg).Vg
-        pv_to_move = str(lv.LvCommon.Devices[0][0])
-        job = vg.Move(pv_to_move, (0, 0), dbus.Array([], '(oii)'), 0, {})
-        self._wait_for_job(job)
-        self.assertEqual(self._refresh(), 0)
+		t = ['Testing', 'tags']
 
-        # Test Vg.Move
-        # TODO Test this more!
-        vg.update()
-        lv.update()
+		vg.TagsAdd(t, -1, {})
+		vg.update()
+		self.assertTrue(t == vg.Tags)
+		vg.TagsDel(t, -1, {})
+		vg.update()
+		self.assertTrue([] == vg.Tags)
 
-        location = lv.LvCommon.Devices[0][0]
+	def test_lv_tags(self):
+		vg = self._vg_create().Vg
+		lv = self._test_lv_create(
+			vg.LvCreateLinear,
+			(rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
+			vg)
 
-        dst = None
-        for p in vg.Pvs:
-            if p != location:
-                dst = p
+		t = ['Testing', 'tags']
 
-        # Fetch the destination
-        pv = ClientProxy(self.bus, dst).Pv
+		lv.Lv.TagsAdd(t, -1, {})
+		lv.update()
+		self.assertTrue(t == lv.LvCommon.Tags)
+		lv.Lv.TagsDel(t, -1, {})
+		lv.update()
+		self.assertTrue([] == lv.LvCommon.Tags)
 
-        # Test range, move it to the middle of the new destination and blocking
-        # blocking for it to complete
-        job = vg.Move(location,
-                      (0, 0), [(dst, pv.PeCount / 2, 0), ], -1, {})
-        self.assertEqual(job, '/')
-        self.assertEqual(self._refresh(), 0)
+	def test_vg_allocation_policy_set(self):
+		vg = self._vg_create().Vg
 
-    def test_job_handling(self):
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
+		for p in ['anywhere', 'contiguous', 'cling', 'normal']:
+			rc = vg.AllocationPolicySet(p, -1, {})
+			self.assertEqual(rc, '/')
+			vg.update()
 
-        vg_name = rs(8, '_vg')
+			prop = getattr(vg, 'Alloc' + p.title())
+			self.assertTrue(prop)
 
-        # Test getting a job right away
-        vg_path, vg_job = self.objs[MANAGER_INT][0].Manager.VgCreate(
-            vg_name, pv_paths,
-            0, {})
+	def test_vg_max_pv(self):
+		vg = self._vg_create().Vg
 
-        self.assertTrue(vg_path == '/')
-        self.assertTrue(vg_job and len(vg_job) > 0)
+		# BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
+		# TODO: Add a test back for larger values here when bug is resolved
+		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
+			rc = vg.MaxPvSet(p, -1, {})
+			self.assertEqual(rc, '/')
+			vg.update()
+			self.assertTrue(vg.MaxPv == p, "Expected %s != Actual %s" %
+							(str(p), str(vg.MaxPv)))
 
-        self._wait_for_job(vg_job)
+	def test_vg_max_lv(self):
+		vg = self._vg_create().Vg
 
-    def _test_expired_timer(self, num_lvs):
-        rc = False
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
+		# BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
+		# TODO: Add a test back for larger values here when bug is resolved
+		for p in [0, 1, 10, 100, 100, 1024, 2 ** 32 - 1]:
+			rc = vg.MaxLvSet(p, -1, {})
+			self.assertEqual(rc, '/')
+			vg.update()
+			self.assertTrue(vg.MaxLv == p, "Expected %s != Actual %s" %
+							(str(p), str(vg.MaxLv)))
 
-        # In small configurations lvm is pretty snappy, so lets create a VG
-        # add a number of LVs and then remove the VG and all the contained
-        # LVs which appears to consistently run a little slow.
+	def test_vg_uuid_gen(self):
+		# TODO renable test case when
+		# https://bugzilla.redhat.com/show_bug.cgi?id=1264169 gets fixed
+		# This was tested with lvmetad disabled and we passed
+		print("\nSkipping Vg.UuidGenerate until BZ: 1264169 resolved\n")
 
-        vg = self._vg_create(pv_paths).Vg
+		if False:
+			vg = self._vg_create().Vg
+			prev_uuid = vg.Uuid
+			rc = vg.UuidGenerate(-1, {})
+			self.assertEqual(rc, '/')
+			vg.update()
+			self.assertTrue(vg.Uuid != prev_uuid, "Expected %s != Actual %s" %
+							(vg.Uuid, prev_uuid))
 
-        for i in range(0, num_lvs):
-            obj_path, job = vg.LvCreateLinear(rs(8, "_lv"),
-                                              1024 * 1024 * 4, False, -1, {})
-            self.assertTrue(job == '/')
+	def test_vg_activate_deactivate(self):
+		vg = self._vg_create().Vg
+		self._test_lv_create(
+			vg.LvCreateLinear,
+			(rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
+			vg)
 
-        # Make sure that we are honoring the timeout
-        start = time.time()
+		vg.update()
 
-        remove_job = vg.Remove(1, {})
+		vg.Deactivate(0, -1, {})
+		self.assertEqual(self._refresh(), 0)
 
-        end = time.time()
+		vg.Activate(0, -1, {})
+		self.assertEqual(self._refresh(), 0)
 
-        tt_remove = float(end) - float(start)
+		# Try control flags
+		for i in range(0, 5):
+			vg.Activate(1 << i, -1, {})
 
-        self.assertTrue(tt_remove < 2.0, "remove time %s" % (str(tt_remove)))
+	def test_pv_resize(self):
 
-        # Depending on how long it took we could finish either way
-        if remove_job != '/':
-            # We got a job
-            result = self._wait_for_job(remove_job)
-            self.assertTrue(result == '/')
-            rc = True
-        else:
-            # It completed before timer popped
-            pass
+		self.assertTrue(len(self.objs[PV_INT]) > 0)
+
+		if len(self.objs[PV_INT]) > 0:
+			pv = ClientProxy(self.bus, self.objs[PV_INT][0].object_path).Pv
+
+			original_size = pv.SizeBytes
+
+			new_size = original_size / 2
 
-        return rc
-
-    def test_job_handling_timer(self):
-
-        yes = False
-
-        # This may not pass
-        for i in [48, 64, 128]:
-            yes = self._test_expired_timer(i)
-            if yes:
-                break
-            print('Attempt (%d) failed, trying again...' % (i))
-
-        self.assertTrue(yes)
-
-    def test_pv_tags(self):
-        pvs = []
-
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
-
-        vg = self._vg_create(pv_paths).Vg
-
-        # Get the PVs
-        for p in vg.Pvs:
-            pvs.append(ClientProxy(self.bus, p).Pv)
-
-        for tags_value in [['hello'], ['foo', 'bar']]:
-            rc = vg.PvTagsAdd(vg.Pvs, tags_value, -1, {})
-            self.assertTrue(rc == '/')
-
-            for p in pvs:
-                p.update()
-                self.assertTrue(sorted(tags_value) == p.Tags)
-
-            vg.PvTagsDel(vg.Pvs, tags_value, -1, {})
-            for p in pvs:
-                p.update()
-                self.assertTrue([] == p.Tags)
-
-    def test_vg_tags(self):
-        vg = self._vg_create().Vg
+			pv.ReSize(new_size, -1, {})
+			self.assertEqual(self._refresh(), 0)
+			pv.update()
 
-        t = ['Testing', 'tags']
+			self.assertTrue(pv.SizeBytes != original_size)
+			pv.ReSize(0, -1, {})
+			self.assertEqual(self._refresh(), 0)
+			pv.update()
+			self.assertTrue(pv.SizeBytes == original_size)
 
-        vg.TagsAdd(t, -1, {})
-        vg.update()
-        self.assertTrue(t == vg.Tags)
-        vg.TagsDel(t, -1, {})
-        vg.update()
-        self.assertTrue([] == vg.Tags)
+	def test_pv_allocation(self):
 
-    def test_lv_tags(self):
-        vg = self._vg_create().Vg
-        lv = self._test_lv_create(
-            vg.LvCreateLinear,
-            (rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
-            vg)
+		pv_paths = []
+		for pp in self.objs[PV_INT]:
+			pv_paths.append(pp.object_path)
 
-        t = ['Testing', 'tags']
+		vg = self._vg_create(pv_paths).Vg
 
-        lv.Lv.TagsAdd(t, -1, {})
-        lv.update()
-        self.assertTrue(t == lv.LvCommon.Tags)
-        lv.Lv.TagsDel(t, -1, {})
-        lv.update()
-        self.assertTrue([] == lv.LvCommon.Tags)
+		pv = ClientProxy(self.bus, vg.Pvs[0]).Pv
 
-    def test_vg_allocation_policy_set(self):
-        vg = self._vg_create().Vg
+		pv.AllocationEnabled(False, -1, {})
+		pv.update()
+		self.assertFalse(pv.Allocatable)
 
-        for p in ['anywhere', 'contiguous', 'cling', 'normal']:
-            rc = vg.AllocationPolicySet(p, -1, {})
-            self.assertEqual(rc, '/')
-            vg.update()
+		pv.AllocationEnabled(True, -1, {})
+		pv.update()
+		self.assertTrue(pv.Allocatable)
 
-            prop = getattr(vg, 'Alloc' + p.title())
-            self.assertTrue(prop)
+		self.assertEqual(self._refresh(), 0)
 
-    def test_vg_max_pv(self):
-        vg = self._vg_create().Vg
+	def _get_devices(self):
+		context = pyudev.Context()
+		return context.list_devices(subsystem='block', MAJOR='8')
 
-        # BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
-        # TODO: Add a test back for larger values here when bug is resolved
-        for p in [0, 1, 10, 100, 100, 1024, 2**32 - 1]:
-            rc = vg.MaxPvSet(p, -1, {})
-            self.assertEqual(rc, '/')
-            vg.update()
-            self.assertTrue(vg.MaxPv == p, "Expected %s != Actual %s" %
-                            (str(p), str(vg.MaxPv)))
+	def test_pv_scan(self):
+		devices = self._get_devices()
 
-    def test_vg_max_lv(self):
-        vg = self._vg_create().Vg
+		mgr = self._manager().Manager
 
-        # BZ: https://bugzilla.redhat.com/show_bug.cgi?id=1280496
-        # TODO: Add a test back for larger values here when bug is resolved
-        for p in [0, 1, 10, 100, 100, 1024, 2**32 - 1]:
-            rc = vg.MaxLvSet(p, -1, {})
-            self.assertEqual(rc, '/')
-            vg.update()
-            self.assertTrue(vg.MaxLv == p, "Expected %s != Actual %s" %
-                            (str(p), str(vg.MaxLv)))
+		self.assertEqual(mgr.PvScan(False, True,
+									dbus.Array([], 's'),
+									dbus.Array([], '(ii)'), -1, {}), '/')
+		self.assertEqual(self._refresh(), 0)
+		self.assertEqual(mgr.PvScan(False, False,
+									dbus.Array([], 's'),
+									dbus.Array([], '(ii)'), -1, {}), '/')
+		self.assertEqual(self._refresh(), 0)
 
-    def test_vg_uuid_gen(self):
-        # TODO renable test case when
-        # https://bugzilla.redhat.com/show_bug.cgi?id=1264169 gets fixed
-        # This was tested with lvmetad disabled and we passed
-        print("\nSkipping Vg.UuidGenerate until BZ: 1264169 resolved\n")
+		block_path = []
+		for d in devices:
+			block_path.append(d['DEVNAME'])
 
-        if False:
-            vg = self._vg_create().Vg
-            prev_uuid = vg.Uuid
-            rc = vg.UuidGenerate(-1, {})
-            self.assertEqual(rc, '/')
-            vg.update()
-            self.assertTrue(vg.Uuid != prev_uuid, "Expected %s != Actual %s" %
-                            (vg.Uuid, prev_uuid))
+		self.assertEqual(mgr.PvScan(False, True,
+									block_path,
+									dbus.Array([], '(ii)'), -1, {}), '/')
 
-    def test_vg_activate_deactivate(self):
-        vg = self._vg_create().Vg
-        self._test_lv_create(
-            vg.LvCreateLinear,
-            (rs(8, '_lv'), 1024 * 1024 * 4, False, -1, {}),
-            vg)
+		self.assertEqual(self._refresh(), 0)
 
-        vg.update()
+		mm = []
+		for d in devices:
+			mm.append((int(d['MAJOR']), int(d['MINOR'])))
 
-        vg.Deactivate(0, -1, {})
-        self.assertEqual(self._refresh(), 0)
+		self.assertEqual(mgr.PvScan(False, True,
+									block_path,
+									mm, -1, {}), '/')
 
-        vg.Activate(0, -1, {})
-        self.assertEqual(self._refresh(), 0)
+		self.assertEqual(self._refresh(), 0)
 
-        # Try control flags
-        for i in range(0, 5):
-            vg.Activate(1 << i, -1, {})
+		self.assertEqual(mgr.PvScan(False, True,
+									dbus.Array([], 's'),
+									mm, -1, {}), '/')
 
-    def test_pv_resize(self):
+		self.assertEqual(self._refresh(), 0)
 
-        self.assertTrue(len(self.objs[PV_INT]) > 0)
-
-        if len(self.objs[PV_INT]) > 0:
-            pv = ClientProxy(self.bus, self.objs[PV_INT][0].object_path).Pv
-
-            original_size = pv.SizeBytes
-
-            new_size = original_size / 2
+	@staticmethod
+	def _write_some_data(device_path, size):
+		blocks = int(size / 512)
+		block = bytearray(512)
+		for i in range(0, 512):
+			block[i] = i % 255
 
-            pv.ReSize(new_size, -1, {})
-            self.assertEqual(self._refresh(), 0)
-            pv.update()
+		with open(device_path, mode='wb') as lv:
+			for i in range(0, blocks):
+				lv.write(block)
 
-            self.assertTrue(pv.SizeBytes != original_size)
-            pv.ReSize(0, -1, {})
-            self.assertEqual(self._refresh(), 0)
-            pv.update()
-            self.assertTrue(pv.SizeBytes == original_size)
+	def test_snapshot_merge(self):
+		# Create a non-thin LV and merge it
+		ss_size = 1024 * 1024 * 512
 
-    def test_pv_allocation(self):
+		lv_p = self._create_lv(size=1024 * 1024 * 1024)
+		ss_name = lv_p.LvCommon.Name + '_snap'
+		snapshot_path = lv_p.Lv.Snapshot(ss_name, ss_size, -1, {})[0]
+		ss = ClientProxy(self.bus, snapshot_path)
 
-        pv_paths = []
-        for pp in self.objs[PV_INT]:
-            pv_paths.append(pp.object_path)
+		# Write some data to snapshot so merge takes some time
+		TestDbusService._write_some_data(ss.LvCommon.Path, ss_size / 2)
 
-        vg = self._vg_create(pv_paths).Vg
+		job_path = ss.Snapshot.Merge(0, {})
 
-        pv = ClientProxy(self.bus, vg.Pvs[0]).Pv
+		self.assertTrue(job_path != '/')
+		self._wait_for_job(job_path)
 
-        pv.AllocationEnabled(False, -1, {})
-        pv.update()
-        self.assertFalse(pv.Allocatable)
+	def test_snapshot_merge_thin(self):
+		# Create a thin LV, snapshot it and merge it
+		tp = self._create_lv(True)
 
-        pv.AllocationEnabled(True, -1, {})
-        pv.update()
-        self.assertTrue(pv.Allocatable)
+		thin_path = tp.ThinPool.LvCreate(
+			rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
 
-        self.assertEqual(self._refresh(), 0)
+		lv_p = ClientProxy(self.bus, thin_path)
 
-    def _get_devices(self):
-        context = pyudev.Context()
-        return context.list_devices(subsystem='block', MAJOR='8')
+		ss_name = lv_p.LvCommon.Name + '_snap'
+		snapshot_path = lv_p.Lv.Snapshot(ss_name, 0, -1, {})[0]
+		ss = ClientProxy(self.bus, snapshot_path)
+		job_path = ss.Snapshot.Merge(0, {})
+		self.assertTrue(job_path != '/')
+		self._wait_for_job(job_path)
 
-    def test_pv_scan(self):
-        devices = self._get_devices()
+	def _create_cache_pool(self):
+		vg = self._vg_create().Vg
 
-        mgr = self._manager().Manager
+		md = self._create_lv(size=(1024 * 1024 * 8), vg=vg)
+		data = self._create_lv(size=(1024 * 1024 * 256), vg=vg)
 
-        self.assertEqual(mgr.PvScan(False, True,
-                                    dbus.Array([], 's'),
-                                    dbus.Array([], '(ii)'), -1, {}), '/')
-        self.assertEqual(self._refresh(), 0)
-        self.assertEqual(mgr.PvScan(False, False,
-                                    dbus.Array([], 's'),
-                                    dbus.Array([], '(ii)'), -1, {}), '/')
-        self.assertEqual(self._refresh(), 0)
+		cache_pool_path = vg.CreateCachePool(
+			md.object_path, data.object_path, -1, {})[0]
 
-        block_path = []
-        for d in devices:
-            block_path.append(d['DEVNAME'])
+		cp = ClientProxy(self.bus, cache_pool_path)
 
-        self.assertEqual(mgr.PvScan(False, True,
-                                    block_path,
-                                    dbus.Array([], '(ii)'), -1, {}), '/')
+		return (vg, cp)
 
-        self.assertEqual(self._refresh(), 0)
+	def test_cache_pool_create(self):
 
-        mm = []
-        for d in devices:
-            mm.append((int(d['MAJOR']), int(d['MINOR'])))
+		vg, cache_pool = self._create_cache_pool()
 
-        self.assertEqual(mgr.PvScan(False, True,
-                                    block_path,
-                                    mm, -1, {}), '/')
+		self.assertTrue('/com/redhat/lvmdbus1/CachePool' in
+						cache_pool.object_path)
 
-        self.assertEqual(self._refresh(), 0)
+	def test_cache_lv_create(self):
 
-        self.assertEqual(mgr.PvScan(False, True,
-                                    dbus.Array([], 's'),
-                                    mm, -1, {}), '/')
+		for destroy_cache in [True, False]:
+			vg, cache_pool = self._create_cache_pool()
 
-        self.assertEqual(self._refresh(), 0)
+			lv_to_cache = self._create_lv(size=(1024 * 1024 * 1024), vg=vg)
 
-    @staticmethod
-    def _write_some_data(device_path, size):
-        blocks = int(size / 512)
-        block = bytearray(512)
-        for i in range(0, 512):
-            block[i] = i % 255
+			c_lv_path = cache_pool.CachePool.CacheLv(
+				lv_to_cache.object_path, -1, {})[0]
 
-        with open(device_path, mode='wb') as lv:
-            for i in range(0, blocks):
-                lv.write(block)
+			cached_lv = ClientProxy(self.bus, c_lv_path)
 
-    def test_snapshot_merge(self):
-        # Create a non-thin LV and merge it
-        ss_size = 1024 * 1024 * 512
+			uncached_lv_path = \
+				cached_lv.CachedLv.DetachCachePool(destroy_cache, -1, {})[0]
 
-        lv_p = self._create_lv(size=1024 * 1024 * 1024)
-        ss_name = lv_p.LvCommon.Name + '_snap'
-        snapshot_path = lv_p.Lv.Snapshot(ss_name, ss_size, -1, {})[0]
-        ss = ClientProxy(self.bus, snapshot_path)
+			self.assertTrue('/com/redhat/lvmdbus1/Lv' in
+							uncached_lv_path)
 
-        # Write some data to snapshot so merge takes some time
-        TestDbusService._write_some_data(ss.LvCommon.Path, ss_size / 2)
+			vg.Remove(-1, {})
 
-        job_path = ss.Snapshot.Merge(0, {})
+	def test_vg_change(self):
+		vg_proxy = self._vg_create()
+		result = vg_proxy.Vg.Change(-1, {'-a': 'ay'})
+		self.assertTrue(result == '/')
+		result = vg_proxy.Vg.Change(-1, {'-a': 'n'})
+		self.assertTrue(result == '/')
 
-        self.assertTrue(job_path != '/')
-        self._wait_for_job(job_path)
+	def _invalid_vg_lv_name_characters(self):
+		bad_vg_lv_set = set(string.printable) - \
+			set(string.ascii_letters + string.digits + '.-_+')
+		return ''.join(bad_vg_lv_set)
 
-    def test_snapshot_merge_thin(self):
-        # Create a thin LV, snapshot it and merge it
-        tp = self._create_lv(True)
+	def test_invalid_names(self):
+		mgr = self.objs[MANAGER_INT][0].Manager
 
-        thin_path = tp.ThinPool.LvCreate(
-            rs(10, '_thin_lv'), 1024 * 1024 * 10, -1, {})[0]
+		# Pv device path
+		with self.assertRaises(dbus.exceptions.DBusException):
+			mgr.PvCreate("/dev/space in name", -1, {})
 
-        lv_p = ClientProxy(self.bus, thin_path)
+		# VG Name testing...
+		# Go through all bad characters
+		pv_paths = [self.objs[PV_INT][0].object_path]
+		bad_chars = self._invalid_vg_lv_name_characters()
+		for c in bad_chars:
+			with self.assertRaises(dbus.exceptions.DBusException):
+				mgr.VgCreate("name%s" % (c), pv_paths, -1, {})
 
-        ss_name = lv_p.LvCommon.Name + '_snap'
-        snapshot_path = lv_p.Lv.Snapshot(ss_name, 0, -1, {})[0]
-        ss = ClientProxy(self.bus, snapshot_path)
-        job_path = ss.Snapshot.Merge(0, {})
-        self.assertTrue(job_path != '/')
-        self._wait_for_job(job_path)
+		# Bad names
+		for bad in [".", ".."]:
+			with self.assertRaises(dbus.exceptions.DBusException):
+				mgr.VgCreate(bad, pv_paths, -1, {})
 
-    def _create_cache_pool(self):
-        vg = self._vg_create().Vg
+		# Exceed name length
+		for i in [128, 1024, 4096]:
+			with self.assertRaises(dbus.exceptions.DBusException):
+				mgr.VgCreate('T' * i, pv_paths, -1, {})
 
-        md = self._create_lv(size=(1024 * 1024 * 8), vg=vg)
-        data = self._create_lv(size=(1024 * 1024 * 256), vg=vg)
+		# Create a VG and try to create LVs with different bad names
+		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_proxy = ClientProxy(self.bus, vg_path)
 
-        cache_pool_path = vg.CreateCachePool(
-            md.object_path, data.object_path, -1, {})[0]
+		for c in bad_chars:
+			with self.assertRaises(dbus.exceptions.DBusException):
+				vg_proxy.Vg.LvCreateLinear(rs(8, '_lv') + c,
+					1024 * 1024 * 4, False, -1, {})
 
-        cp = ClientProxy(self.bus, cache_pool_path)
+		for r in ("_cdata", "_cmeta", "_corig", "_mimage", "_mlog",
+			"_pmspare", "_rimage", "_rmeta", "_tdata", "_tmeta", "_vorigin"):
+			with self.assertRaises(dbus.exceptions.DBusException):
+				vg_proxy.Vg.LvCreateLinear(rs(8, '_lv') + r,
+					1024 * 1024 * 4, False, -1, {})
 
-        return (vg, cp)
+		for r in ("snapshot", "pvmove"):
+			with self.assertRaises(dbus.exceptions.DBusException):
+				vg_proxy.Vg.LvCreateLinear(r + rs(8, '_lv'),
+					1024 * 1024 * 4, False, -1, {})
 
-    def test_cache_pool_create(self):
+	_ALLOWABLE_TAG_CH = string.ascii_letters + string.digits + "._-+/=!:&#"
 
-        vg, cache_pool = self._create_cache_pool()
+	def _invalid_tag_characters(self):
+		bad_tag_ch_set = set(string.printable) - set(self._ALLOWABLE_TAG_CH)
+		return ''.join(bad_tag_ch_set)
 
-        self.assertTrue('/com/redhat/lvmdbus1/CachePool' in
-                        cache_pool.object_path)
+	def test_invalid_tags(self):
+		mgr = self.objs[MANAGER_INT][0].Manager
+		pv_paths = [self.objs[PV_INT][0].object_path]
 
-    def test_cache_lv_create(self):
+		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_proxy = ClientProxy(self.bus, vg_path)
 
-        for destroy_cache in [True, False]:
-            vg, cache_pool = self._create_cache_pool()
+		for c in self._invalid_tag_characters():
+			with self.assertRaises(dbus.exceptions.DBusException):
+				vg_proxy.Vg.TagsAdd([c], -1, {})
 
-            lv_to_cache = self._create_lv(size=(1024 * 1024 * 1024), vg=vg)
+		for c in self._invalid_tag_characters():
+			with self.assertRaises(dbus.exceptions.DBusException):
+				vg_proxy.Vg.TagsAdd(["a%sb" % (c)], -1, {})
 
-            c_lv_path = cache_pool.CachePool.CacheLv(
-                lv_to_cache.object_path, -1, {})[0]
+	def test_tag_names(self):
+		mgr = self.objs[MANAGER_INT][0].Manager
+		pv_paths = [self.objs[PV_INT][0].object_path]
 
-            cached_lv = ClientProxy(self.bus, c_lv_path)
+		vg_path = mgr.VgCreate("test", pv_paths, -1, {})[0]
+		vg_proxy = ClientProxy(self.bus, vg_path)
 
-            uncached_lv_path = \
-                cached_lv.CachedLv.DetachCachePool(destroy_cache, -1, {})[0]
+		for i in range(1, 64):
+			tag = rs(i, "", self._ALLOWABLE_TAG_CH)
+			r = vg_proxy.Vg.TagsAdd([tag], -1, {})
+			self.assertTrue(r == '/')
+			vg_proxy.update()
 
-            self.assertTrue('/com/redhat/lvmdbus1/Lv' in
-                            uncached_lv_path)
+			self.assertTrue(tag in vg_proxy.Vg.Tags, "%s not in %s" %
+				(tag, str(vg_proxy.Vg.Tags)))
 
-            vg.Remove(-1, {})
+			self.assertEqual(i, len(vg_proxy.Vg.Tags), "%d != %d" %
+				(i, len(vg_proxy.Vg.Tags)))
 
-    def test_vg_change(self):
-        vg_proxy = self._vg_create()
-        result = vg_proxy.Vg.Change(-1, {'-a': 'ay'})
-        self.assertTrue(result == '/')
-        result = vg_proxy.Vg.Change(-1, {'-a': 'n'})
-        self.assertTrue(result == '/')
 
 if __name__ == '__main__':
-    # Test forking & exec new each time
-    test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 0)
-
-    set_execution(False)
-
-    if test_shell == 0:
-        unittest.main(exit=True)
-    else:
-        unittest.main(exit=False)
-        # Test lvm shell
-        print('\n *** Testing lvm shell *** \n')
-        set_execution(True)
-        unittest.main()
+	# Test forking & exec new each time
+	test_shell = os.getenv('LVM_DBUS_TEST_SHELL', 0)
+
+	set_execution(False)
+
+	if test_shell == 0:
+		unittest.main(exit=True)
+	else:
+		unittest.main(exit=False)
+		# Test lvm shell
+		print('\n *** Testing lvm shell *** \n')
+		set_execution(True)
+		unittest.main()


