From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:55 +0000 (UTC)
Subject: master - lvmdbustest: Reduce dbus object churn
Message-ID: <20161117173655.1197860C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bd47b202fb373a93761e038afe39fb6aeee89289
Commit:        bd47b202fb373a93761e038afe39fb6aeee89289
Parent:        bfedeb748149c61caab44957c0a4f54fe57d6823
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 17 10:34:07 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbustest: Reduce dbus object churn

Instead of creating a new dbus object each time we get an interface object
we will use the same one.
---
 test/dbus/testlib.py |   41 ++++++++++++++++++++++-------------------
 1 files changed, 22 insertions(+), 19 deletions(-)

diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index e0c26a8..89e73d2 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -167,9 +167,7 @@ class RemoteInterface(object):
 		if not props:
 			for _ in range(0, 3):
 				try:
-					prop_obj = self.bus.get_object(
-						BUS_NAME, self.object_path, introspect=False)
-					prop_interface = dbus.Interface(prop_obj,
+					prop_interface = dbus.Interface(self.dbus_object,
 						'org.freedesktop.DBus.Properties')
 					props = prop_interface.GetAll(self.interface)
 					break
@@ -184,29 +182,28 @@ class RemoteInterface(object):
 					['properties'][kl]['p_type'])
 				setattr(self, kl, vl)
 
+	@property
+	def object_path(self):
+		return self.dbus_object.object_path
+
 	def __init__(
-			self, specified_bus, object_path, interface, introspect,
+			self, dbus_object, interface, introspect,
 			properties=None):
-		self.object_path = object_path
+		self.dbus_object = dbus_object
 		self.interface = interface
-		self.bus = specified_bus
 		self.introspect = introspect
 
-		self.dbus_method = dbus.Interface(specified_bus.get_object(
-			BUS_NAME, self.object_path, introspect=False), self.interface)
-
+		self.dbus_interface = dbus.Interface(self.dbus_object, self.interface)
 		self._set_props(properties)
 
 	def __getattr__(self, item):
-		if hasattr(self.dbus_method, item):
+		if hasattr(self.dbus_interface, item):
 			return functools.partial(self._wrapper, item)
 		else:
 			return functools.partial(self, item)
 
 	def _wrapper(self, _method_name, *args, **kwargs):
-		result = getattr(self.dbus_method, _method_name)(*args, **kwargs)
-		# print("DEBUG: %s.%s result %s" %
-		# (self.interface, _method_name, str(type(result))))
+		result = getattr(self.dbus_interface, _method_name)(*args, **kwargs)
 
 		if self.introspect:
 			if 'RETURN_VALUE' in self.introspect[
@@ -229,24 +226,25 @@ class ClientProxy(object):
 		return nm.split('.')[-1:][0]
 
 	def get_introspect(self):
-		i = dbus.Interface(self.bus.get_object(
-			BUS_NAME, self.object_path, introspect=False),
-			'org.freedesktop.DBus.Introspectable')
+		i = dbus.Interface(
+				self.dbus_object,
+				'org.freedesktop.DBus.Introspectable')
 
 		return DbusIntrospection.introspect(i.Introspect())
 
 	def _common(self, interface, introspect, properties):
 		short_name = ClientProxy._intf_short_name(interface)
 		self.short_interface_names.append(short_name)
-		ro = RemoteInterface(self.bus, self.object_path, interface, introspect,
+		ro = RemoteInterface(self.dbus_object, interface, introspect,
 								properties)
 		setattr(self, short_name, ro)
 
-	def __init__(self, specified_bus, object_path, interface_prop_hash=None,
+	def __init__(self, bus, object_path, interface_prop_hash=None,
 					interfaces=None):
 		self.object_path = object_path
 		self.short_interface_names = []
-		self.bus = specified_bus
+		self.dbus_object = bus.get_object(
+			BUS_NAME, self.object_path, introspect=False)
 
 		if interface_prop_hash:
 			assert interfaces is None
@@ -267,6 +265,11 @@ class ClientProxy(object):
 			# will also utilize it to verify what we get back verifies
 			introspect = self.get_introspect()
 
+			if interface_prop_hash:
+				introspect_interfaces = list(introspect.keys())
+				for object_manager_key in interface_prop_hash.keys():
+					assert object_manager_key in introspect_interfaces
+
 			for i in list(introspect.keys()):
 				self._common(i, introspect, None)
 


