From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:51 +0000 (UTC)
Subject: master - dbus/testlib.py: Improve type checking
Message-ID: <20160829202851.4BAA560D22@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=313c40ed09d4eedba208a50c783d8d20e32de92e
Commit:        313c40ed09d4eedba208a50c783d8d20e32de92e
Parent:        9241dbdf57c997bcb8467b823cae6aee7faab03b
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 12:34:19 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

dbus/testlib.py: Improve type checking

Leverage the introspection data to ensure that the service is returning
what is says it will be returning for methods and properties.
---
 test/dbus/testlib.py |  108 +++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 93 insertions(+), 15 deletions(-)

diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 550b0bf..712b13a 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -63,7 +63,7 @@ class DbusIntrospection(object):
 								if arg_dir == 'in':
 									n = arg.attrib['name']
 								else:
-									n = None
+									n = 'RETURN_VALUE'
 
 								arg_type = arg.attrib['type']
 
@@ -86,20 +86,73 @@ class DbusIntrospection(object):
 
 		# print('Interfaces...')
 		# for k, v in list(interfaces.items()):
-		#     print('Interface %s' % k)
-		#     if v['methods']:
-		#         for m, args in list(v['methods'].items()):
-		#             print('    method: %s' % m)
-		#             for a, aa in args.items():
-		#                 print('         method arg: %s' % (a))
-		#     if v['properties']:
-		#         for p, d in list(v['properties'].items()):
-		#             print('    Property: %s' % (p))
+		# 	print('Interface %s' % k)
+		# 	if v['methods']:
+		# 		for m, args in list(v['methods'].items()):
+		# 			print('    method: %s' % m)
+		# 			for a, aa in args.items():
+		# 				print('         method arg: %s type %s' %
+		# 					  (a, aa['a_type']))
+		# 	if v['properties']:
+		# 		for p, d in list(v['properties'].items()):
+		# 			print('    Property: %s type= %s' % (p, d['p_type']))
 		# print('End interfaces')
 
 		return interfaces
 
 
+def btsr(value):
+	t = type(value)
+	if t ==  dbus.Boolean:
+		return 'b'
+	elif t == dbus.ObjectPath:
+		return 'o'
+	elif t == dbus.String:
+		return 's'
+	elif t == dbus.Byte:
+		return 'y'
+	elif t == dbus.Int16:
+		return 'n'
+	elif t == dbus.Int32:
+		return 'i'
+	elif t == dbus.Int64:
+		return 'x'
+	elif t == dbus.UInt16:
+		return 'q'
+	elif t == dbus.UInt32:
+		return 'u'
+	elif t == dbus.UInt64:
+		return 't'
+	elif t == dbus.Double:
+		return 'd'
+	elif t == dbus.Struct:
+		rc = '('
+		for vt in value:
+			rc += btsr(vt)
+		rc += ')'
+		return rc
+	elif t == dbus.Array:
+		rc = "a"
+		for i in value:
+			rc += btsr(i)
+			break
+		return rc
+	else:
+		raise RuntimeError("Unhandled type %s" % str(t))
+
+
+def verify_type(value, dbus_str_rep):
+	actual_str_rep = btsr(value)
+
+	if dbus_str_rep != actual_str_rep:
+		# print("%s ~= %s" % (dbus_str_rep, actual_str_rep))
+		# Unless we have a full filled out type we won't match exactly
+		if not dbus_str_rep.startswith(actual_str_rep):
+			raise RuntimeError("Incorrect type, expected= %s actual "
+								"= %s object= %s" %
+								(dbus_str_rep, actual_str_rep,
+								str(type(value))))
+
 class RemoteObject(object):
 	def _set_props(self, props=None):
 		# print 'Fetching properties'
@@ -119,12 +172,16 @@ class RemoteObject(object):
 						raise dbe
 		if props:
 			for kl, vl in list(props.items()):
+				# Verify type is correct!
+				verify_type(vl,
+					self.introspect[self.interface]['properties'][kl]['p_type'])
 				setattr(self, kl, vl)
 
-	def __init__(self, specified_bus, object_path, interface, properties=None):
+	def __init__(self, specified_bus, object_path, interface, introspect, properties=None):
 		self.object_path = object_path
 		self.interface = interface
 		self.bus = specified_bus
+		self.introspect = introspect
 
 		self.dbus_method = dbus.Interface(specified_bus.get_object(
 			BUSNAME, self.object_path), self.interface)
@@ -138,7 +195,18 @@ class RemoteObject(object):
 			return functools.partial(self, item)
 
 	def _wrapper(self, _method_name, *args, **kwargs):
-		return getattr(self.dbus_method, _method_name)(*args, **kwargs)
+		result = getattr(self.dbus_method, _method_name)(*args, **kwargs)
+		#print("DEBUG: %s.%s result %s" %
+		#	(self.interface, _method_name, str(type(result))))
+
+		if 'RETURN_VALUE' in \
+				self.introspect[self.interface]['methods'][_method_name]:
+			r_type = self.introspect[self.interface]['methods'] \
+				[_method_name]['RETURN_VALUE']['a_type']
+
+			verify_type(result, r_type)
+
+		return result
 
 	def update(self):
 		self._set_props()
@@ -152,16 +220,26 @@ class ClientProxy(object):
 	def __init__(self, specified_bus, object_path, interface=None, props=None):
 		i = dbus.Interface(specified_bus.get_object(
 			BUSNAME, object_path), 'org.freedesktop.DBus.Introspectable')
-		self.intro_spect = DbusIntrospection.introspect(i.Introspect())
+
+		introspection_xml = i.Introspect()
+
+		# import xml.dom.minidom
+		#
+		# xml = xml.dom.minidom.parseString(introspection_xml)
+		# print(xml.toprettyxml())
+
+		self.intro_spect = DbusIntrospection.introspect(introspection_xml)
 
 		for k in self.intro_spect.keys():
 			sn = ClientProxy._intf_short_name(k)
 			# print('Client proxy has interface: %s %s' % (k, sn))
 
 			if interface and interface == k and props is not None:
-				ro = RemoteObject(specified_bus, object_path, k, props)
+				ro = RemoteObject(specified_bus, object_path, k,
+								  self.intro_spect, props)
 			else:
-				ro = RemoteObject(specified_bus, object_path, k)
+				ro = RemoteObject(specified_bus, object_path, k,
+								  self.intro_spect)
 
 			setattr(self, sn, ro)
 


