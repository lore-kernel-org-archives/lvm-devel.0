From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:18 -0400
Subject: master - testlib.py: WS corrections
Message-ID: <201910301545.x9UFjIfQ016912@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b7aab9ba594b9b627ec09b8e0dab5cd75e7178cf
Commit:        b7aab9ba594b9b627ec09b8e0dab5cd75e7178cf
Parent:        89373761c808c21181751d622e987b323355b677
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Oct 9 19:59:44 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

testlib.py: WS corrections

---
 test/dbus/testlib.py |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index bf88beb..ad2d93b 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -169,8 +169,8 @@ class RemoteInterface(object):
 		if not props:
 			for _ in range(0, 3):
 				try:
-					prop_interface = dbus.Interface(self.dbus_object,
-						'org.freedesktop.DBus.Properties')
+					prop_interface = dbus.Interface(
+						self.dbus_object, 'org.freedesktop.DBus.Properties')
 					props = prop_interface.GetAll(self.interface)
 					break
 				except dbus.exceptions.DBusException as dbe:
@@ -180,8 +180,9 @@ class RemoteInterface(object):
 			for kl, vl in list(props.items()):
 				# Verify type is correct!
 				if self.introspect:
-					verify_type(vl, self.introspect[self.interface]
-					['properties'][kl]['p_type'])
+					verify_type(
+						vl, self.introspect[self.interface]
+						['properties'][kl]['p_type'])
 				setattr(self, kl, vl)
 
 	@property
@@ -189,8 +190,8 @@ class RemoteInterface(object):
 		return self.dbus_object.object_path
 
 	def __init__(
-			self, dbus_object, interface, introspect,
-			properties=None, timelimit=-1):
+			self, dbus_object, interface,
+			introspect, properties=None, timelimit=-1):
 		self.dbus_object = dbus_object
 		self.interface = interface
 		self.introspect = introspect
@@ -203,6 +204,7 @@ class RemoteInterface(object):
 		self.dbus_interface = dbus.Interface(self.dbus_object, self.interface)
 		self._set_props(properties)
 
+	# noinspection PyTypeChecker
 	def __getattr__(self, item):
 		if hasattr(self.dbus_interface, item):
 			return functools.partial(self._wrapper, item)
@@ -221,8 +223,9 @@ class RemoteInterface(object):
 
 		if self.tmo > 0.0:
 			if diff > self.tmo:
-				std_err_print("\n Time exceeded: %f > %f %s" %
-								(diff, self.tmo, _method_name))
+				std_err_print(
+					"\n Time exceeded: %f > %f %s" %
+					(diff, self.tmo, _method_name))
 
 		if self.introspect:
 			if 'RETURN_VALUE' in self.introspect[
@@ -259,12 +262,14 @@ class ClientProxy(object):
 	def _common(self, interface, introspect, properties):
 		short_name = ClientProxy._intf_short_name(interface)
 		self.short_interface_names.append(short_name)
-		ro = RemoteInterface(self.dbus_object, interface, introspect,
-								properties, timelimit=self.tmo)
+		ro = RemoteInterface(
+			self.dbus_object, interface, introspect, properties,
+			timelimit=self.tmo)
 		setattr(self, short_name, ro)
 
-	def __init__(self, bus, object_path, interface_prop_hash=None,
-					interfaces=None, timelimit=-1):
+	def __init__(
+			self, bus, object_path, interface_prop_hash=None,
+			interfaces=None, timelimit=-1):
 		self.object_path = object_path
 		self.short_interface_names = []
 		self.tmo = timelimit


