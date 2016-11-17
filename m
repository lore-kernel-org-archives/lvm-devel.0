From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:27 +0000 (UTC)
Subject: master - lvmdbus: Make bus name configurable
Message-ID: <20161117173627.BADA3605B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=affe2cebf51169bff01fe20d9f4f1298bba9e1f9
Commit:        affe2cebf51169bff01fe20d9f4f1298bba9e1f9
Parent:        560229178cec9daff0c0f4fe16f59013d566f1d5
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Nov 4 13:26:31 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbus: Make bus name configurable

Add env LVM_DBUS_NAME to change what the bus name is.
---
 daemons/lvmdbusd/cfg.py  |    1 +
 daemons/lvmdbusd/main.py |    4 ++--
 test/dbus/lvmdbustest.py |    5 ++---
 test/dbus/testlib.py     |   34 ++++++++++++++++++----------------
 4 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index 8965ec7..e5bd9e2 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -44,6 +44,7 @@ worker_q = queue.Queue()
 # Main event loop
 loop = None
 
+BUS_NAME = os.getenv('LVM_DBUS_NAME', 'com.redhat.lvmdbus1')
 BASE_INTERFACE = 'com.redhat.lvmdbus1'
 PV_INTERFACE = BASE_INTERFACE + '.Pv'
 VG_INTERFACE = BASE_INTERFACE + '.Vg'
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 7d10bc3..80a576a 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -10,7 +10,7 @@
 from . import cfg
 from . import objectmanager
 from . import utils
-from .cfg import BASE_INTERFACE, BASE_OBJ_PATH, MANAGER_OBJ_PATH
+from .cfg import BUS_NAME, BASE_INTERFACE, BASE_OBJ_PATH, MANAGER_OBJ_PATH
 import threading
 from . import cmdhandler
 import time
@@ -148,7 +148,7 @@ def main():
 		cfg.bus = dbus.SystemBus()
 	# The base name variable needs to exist for things to work.
 	# noinspection PyUnusedLocal
-	base_name = dbus.service.BusName(BASE_INTERFACE, cfg.bus)
+	base_name = dbus.service.BusName(BUS_NAME, cfg.bus)
 	cfg.om = Lvm(BASE_OBJ_PATH)
 	cfg.om.register_object(Manager(MANAGER_OBJ_PATH))
 
diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 7e3a877..09f1b77 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -17,7 +17,6 @@ import unittest
 import sys
 import time
 import pyudev
-import os
 from testlib import *
 
 g_tmo = 0
@@ -56,7 +55,7 @@ def get_objects():
 		CACHE_POOL_INT: [], CACHE_LV_INT: []}
 
 	manager = dbus.Interface(bus.get_object(
-		BUSNAME, "/com/redhat/lvmdbus1"),
+		BUS_NAME, "/com/redhat/lvmdbus1"),
 		"org.freedesktop.DBus.ObjectManager")
 
 	objects = manager.GetManagedObjects()
@@ -71,7 +70,7 @@ def get_objects():
 
 def set_execution(lvmshell):
 	lvm_manager = dbus.Interface(bus.get_object(
-		BUSNAME, "/com/redhat/lvmdbus1/Manager"),
+		BUS_NAME, "/com/redhat/lvmdbus1/Manager"),
 		"com.redhat.lvmdbus1.Manager")
 	return lvm_manager.UseLvmShell(lvmshell)
 
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index d88ebbd..7f8456f 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -14,19 +14,21 @@ import functools
 import xml.etree.ElementTree as Et
 from collections import OrderedDict
 import dbus
-
-BUSNAME = "com.redhat.lvmdbus1"
-MANAGER_INT = BUSNAME + '.Manager'
-MANAGER_OBJ = '/' + BUSNAME.replace('.', '/') + '/Manager'
-PV_INT = BUSNAME + ".Pv"
-VG_INT = BUSNAME + ".Vg"
-LV_INT = BUSNAME + ".Lv"
-THINPOOL_INT = BUSNAME + ".ThinPool"
-SNAPSHOT_INT = BUSNAME + ".Snapshot"
-LV_COMMON_INT = BUSNAME + ".LvCommon"
-JOB_INT = BUSNAME + ".Job"
-CACHE_POOL_INT = BUSNAME + ".CachePool"
-CACHE_LV_INT = BUSNAME + ".CachedLv"
+import os
+
+BUS_NAME = os.getenv('LVM_DBUS_NAME', 'com.redhat.lvmdbus1')
+BASE_INTERFACE = 'com.redhat.lvmdbus1'
+MANAGER_INT = BASE_INTERFACE + '.Manager'
+MANAGER_OBJ = '/' + BASE_INTERFACE.replace('.', '/') + '/Manager'
+PV_INT = BASE_INTERFACE + ".Pv"
+VG_INT = BASE_INTERFACE + ".Vg"
+LV_INT = BASE_INTERFACE + ".Lv"
+THINPOOL_INT = BASE_INTERFACE + ".ThinPool"
+SNAPSHOT_INT = BASE_INTERFACE + ".Snapshot"
+LV_COMMON_INT = BASE_INTERFACE + ".LvCommon"
+JOB_INT = BASE_INTERFACE + ".Job"
+CACHE_POOL_INT = BASE_INTERFACE + ".CachePool"
+CACHE_LV_INT = BASE_INTERFACE + ".CachedLv"
 
 THINPOOL_LV_PATH = '/' + THINPOOL_INT.replace('.', '/')
 
@@ -162,7 +164,7 @@ class RemoteObject(object):
 			for i in range(0, 3):
 				try:
 					prop_fetch = dbus.Interface(self.bus.get_object(
-						BUSNAME, self.object_path),
+						BUS_NAME, self.object_path),
 						'org.freedesktop.DBus.Properties')
 					props = prop_fetch.GetAll(self.interface)
 					break
@@ -186,7 +188,7 @@ class RemoteObject(object):
 		self.introspect = introspect
 
 		self.dbus_method = dbus.Interface(specified_bus.get_object(
-			BUSNAME, self.object_path), self.interface)
+			BUS_NAME, self.object_path), self.interface)
 
 		self._set_props(properties)
 
@@ -222,7 +224,7 @@ class ClientProxy(object):
 
 	def __init__(self, specified_bus, object_path, interface=None, props=None):
 		i = dbus.Interface(specified_bus.get_object(
-			BUSNAME, object_path), 'org.freedesktop.DBus.Introspectable')
+			BUS_NAME, object_path), 'org.freedesktop.DBus.Introspectable')
 
 		introspection_xml = i.Introspect()
 


