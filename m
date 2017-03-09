From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:41:22 -0500
Subject: master - lvmdbusd: Use work queue for queries too
Message-ID: <201703092241.v29MfMsS017958@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e53454d6de07de56736303dd2157c3859f6fa848
Commit:        e53454d6de07de56736303dd2157c3859f6fa848
Parent:        470a1f1c5031590823f8a58e641873da76dc1f46
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Mar 8 15:31:45 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbusd: Use work queue for queries too

We need to place query operations in the queue to prevent the case where
a client knows of something before the service does.  For example if a
client creates a PV/VG/LV outside of the dbus API and then immediately
tries to lookup and use that resource in the lvm dbus service it should
be present.  By placing the queries in the work queue any previous
refresh operation will complete before we process the query.
---
 daemons/lvmdbusd/automatedproperties.py |   45 ++++++++++++++++++++++--------
 daemons/lvmdbusd/cfg.py                 |    3 ++
 daemons/lvmdbusd/main.py                |    3 +-
 daemons/lvmdbusd/manager.py             |   33 ++++++++++++++++------
 daemons/lvmdbusd/objectmanager.py       |   18 ++++++++----
 daemons/lvmdbusd/udevwatch.py           |   12 +++++++-
 6 files changed, 85 insertions(+), 29 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index 7b22d19..68cea6e 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -38,7 +38,7 @@ class AutomatedProperties(dbus.service.Object):
 		props = {}
 
 		for i in self.interface():
-			props[i] = self.GetAll(i)
+			props[i] = AutomatedProperties._get_all_prop(self, i)
 
 		return self._ap_o_path, props
 
@@ -65,33 +65,54 @@ class AutomatedProperties(dbus.service.Object):
 
 		return self._ap_interface
 
-	# Properties
-	# noinspection PyUnusedLocal
-	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
-							in_signature='ss', out_signature='v')
-	def Get(self, interface_name, property_name):
-		value = getattr(self, property_name)
+	@staticmethod
+	def _get_prop(obj, interface_name, property_name):
+		value = getattr(obj, property_name)
 		# Note: If we get an exception in this handler we won't know about it,
 		# only the side effect of no returned value!
 		log_debug('Get (%s), type (%s), value(%s)' %
 					(property_name, str(type(value)), str(value)))
 		return value
 
+	# Properties
+	# noinspection PyUnusedLocal
 	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
-							in_signature='s', out_signature='a{sv}')
-	def GetAll(self, interface_name):
-		if interface_name in self.interface(True):
+							in_signature='ss', out_signature='v',
+							async_callbacks=('cb', 'cbe'))
+	def Get(self, interface_name, property_name, cb, cbe):
+		# Note: If we get an exception in this handler we won't know about it,
+		# only the side effect of no returned value!
+		r = cfg.create_request_entry(
+			-1, AutomatedProperties._get_prop,
+			(self, interface_name, property_name),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+
+	@staticmethod
+	def _get_all_prop(obj, interface_name):
+		if interface_name in obj.interface(True):
 			# Using introspection, lets build this dynamically
-			properties = get_properties(self)
+			properties = get_properties(obj)
 			if interface_name in properties:
 				return properties[interface_name][1]
 			return {}
 		raise dbus.exceptions.DBusException(
-			self._ap_interface,
+			obj._ap_interface,
 			'The object %s does not implement the %s interface'
 			% (self.__class__, interface_name))
 
 	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
+							in_signature='s', out_signature='a{sv}',
+							async_callbacks=('cb', 'cbe'))
+	def GetAll(self, interface_name, cb, cbe):
+		r = cfg.create_request_entry(
+			-1, AutomatedProperties._get_all_prop,
+			(self, interface_name),
+			cb, cbe, False)
+		cfg.worker_q.put(r)
+
+	@dbus.service.method(dbus_interface=dbus.PROPERTIES_IFACE,
 							in_signature='ssv')
 	def Set(self, interface_name, property_name, new_value):
 		setattr(self, property_name, new_value)
diff --git a/daemons/lvmdbusd/cfg.py b/daemons/lvmdbusd/cfg.py
index afb682c..f3eadf1 100644
--- a/daemons/lvmdbusd/cfg.py
+++ b/daemons/lvmdbusd/cfg.py
@@ -84,3 +84,6 @@ db = None
 
 # lvm flight recorder
 blackbox = None
+
+# RequestEntry ctor
+create_request_entry = None
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 17e2175..ff97683 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -30,6 +30,7 @@ import argparse
 import os
 import sys
 from .cmdhandler import LvmFlightRecorder
+from .request import RequestEntry
 
 
 class Lvm(objectmanager.ObjectManager):
@@ -97,6 +98,7 @@ def main():
 	os.environ["LC_ALL"] = "C"
 
 	cfg.args = parser.parse_args()
+	cfg.create_request_entry = RequestEntry
 
 	# We create a flight recorder in cmdhandler too, but we replace it here
 	# as the user may be specifying a different size.  The default one in
@@ -144,7 +146,6 @@ def main():
 	thread_list.append(updater.thread)
 
 	cfg.load = updater.load
-	cfg.event = updater.event
 
 	cfg.loop = GLib.MainLoop()
 
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 5575e39..6d122ba 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -139,11 +139,20 @@ class Manager(AutomatedProperties):
 		Dump the flight recorder to syslog
 		"""
 		cfg.blackbox.dump()
+
+	@staticmethod
+	def _lookup_by_lvm_id(key):
+		p = cfg.om.get_object_path_by_uuid_lvm_id(key, key)
+		if p:
+			return p
+		return '/'
+
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
 		in_signature='s',
-		out_signature='o')
-	def LookUpByLvmId(self, key):
+		out_signature='o',
+		async_callbacks=('cb', 'cbe'))
+	def LookUpByLvmId(self, key, cb, cbe):
 		"""
 		Given a lvm id in one of the forms:
 
@@ -157,10 +166,8 @@ class Manager(AutomatedProperties):
 		:param key: The lookup value
 		:return: Return the object path.  If object not found you will get '/'
 		"""
-		p = cfg.om.get_object_path_by_uuid_lvm_id(key, key)
-		if p:
-			return p
-		return '/'
+		r = RequestEntry(-1, Manager._lookup_by_lvm_id, (key,), cb, cbe, False)
+		cfg.worker_q.put(r)
 
 	@staticmethod
 	def _use_lvm_shell(yes_no):
@@ -181,11 +188,17 @@ class Manager(AutomatedProperties):
 		r = RequestEntry(-1, Manager._use_lvm_shell, (yes_no,), cb, cbe, False)
 		cfg.worker_q.put(r)
 
+	@staticmethod
+	def _external_event(command):
+		utils.log_debug("Processing _external_event= %s" % command,
+							'bg_black', 'fg_orange')
+		cfg.load()
+
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
 		in_signature='s', out_signature='i')
 	def ExternalEvent(self, command):
-
+		utils.log_debug("ExternalEvent %s" % command)
 		# If a user didn't explicitly specify udev, we will turn it off now.
 		if not cfg.args.use_udev:
 			if udevwatch.remove():
@@ -193,8 +206,10 @@ class Manager(AutomatedProperties):
 								"udev monitoring")
 				# We are dependent on external events now to stay current!
 				cfg.ee = True
-		utils.log_debug("ExternalEvent %s" % command)
-		cfg.event()
+
+		r = RequestEntry(
+			-1, Manager._external_event, (command,), None, None, False)
+		cfg.worker_q.put(r)
 		return dbus.Int32(0)
 
 	@staticmethod
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index 71149a5..a9d13a7 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -32,14 +32,12 @@ class ObjectManager(AutomatedProperties):
 		self._id_to_object_path = {}
 		self.rlock = threading.RLock()
 
-	@dbus.service.method(
-		dbus_interface="org.freedesktop.DBus.ObjectManager",
-		out_signature='a{oa{sa{sv}}}')
-	def GetManagedObjects(self):
-		with self.rlock:
+	@staticmethod
+	def _get_managed_objects(obj):
+		with obj.rlock:
 			rc = {}
 			try:
-				for k, v in list(self._objects.items()):
+				for k, v in list(obj._objects.items()):
 					path, props = v[0].emit_data()
 					rc[path] = props
 			except Exception:
@@ -47,6 +45,14 @@ class ObjectManager(AutomatedProperties):
 				sys.exit(1)
 			return rc
 
+	@dbus.service.method(
+		dbus_interface="org.freedesktop.DBus.ObjectManager",
+		out_signature='a{oa{sa{sv}}}', async_callbacks=('cb', 'cbe'))
+	def GetManagedObjects(self, cb, cbe):
+		r = cfg.create_request_entry(-1, ObjectManager._get_managed_objects,
+									(self, ), cb, cbe, False)
+		cfg.worker_q.put(r)
+
 	def locked(self):
 		"""
 		If some external code need to run across a number of different
diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
index e2ac63a..eaf31df 100644
--- a/daemons/lvmdbusd/udevwatch.py
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -10,11 +10,18 @@
 import pyudev
 import threading
 from . import cfg
+from .request import RequestEntry
+from . import utils
 
 observer = None
 observer_lock = threading.RLock()
 
 
+def _udev_event():
+	utils.log_debug("Processing udev event")
+	cfg.load()
+
+
 # noinspection PyUnusedLocal
 def filter_event(action, device):
 	# Filter for events of interest and add a request object to be processed
@@ -37,7 +44,10 @@ def filter_event(action, device):
 		refresh = True
 
 	if refresh:
-		cfg.event()
+		# Place this on the queue so any other operations will sequence behind it
+		r = RequestEntry(
+			-1, _udev_event, (), None, None, False)
+		cfg.worker_q.put(r)
 
 
 def add():


