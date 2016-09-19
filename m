From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:31 +0000 (UTC)
Subject: master - lvmdbustest: ws fix-ups
Message-ID: <20160919203831.8CDA660D98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c23d5f63fdc7c56b41d8863e4bb4c20bfc1950f3
Commit:        c23d5f63fdc7c56b41d8863e4bb4c20bfc1950f3
Parent:        9cb886551160cecc50a20d1867aaa5e1e75b61a6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 19 10:20:12 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:32:47 2016 -0500

lvmdbustest: ws fix-ups

---
 test/dbus/testlib.py |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 712b13a..b382482 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -103,7 +103,7 @@ class DbusIntrospection(object):
 
 def btsr(value):
 	t = type(value)
-	if t ==  dbus.Boolean:
+	if t == dbus.Boolean:
 		return 'b'
 	elif t == dbus.ObjectPath:
 		return 'o'
@@ -153,6 +153,7 @@ def verify_type(value, dbus_str_rep):
 								(dbus_str_rep, actual_str_rep,
 								str(type(value))))
 
+
 class RemoteObject(object):
 	def _set_props(self, props=None):
 		# print 'Fetching properties'
@@ -177,7 +178,8 @@ class RemoteObject(object):
 					self.introspect[self.interface]['properties'][kl]['p_type'])
 				setattr(self, kl, vl)
 
-	def __init__(self, specified_bus, object_path, interface, introspect, properties=None):
+	def __init__(self, specified_bus, object_path, interface, introspect,
+				 properties=None):
 		self.object_path = object_path
 		self.interface = interface
 		self.bus = specified_bus
@@ -196,13 +198,14 @@ class RemoteObject(object):
 
 	def _wrapper(self, _method_name, *args, **kwargs):
 		result = getattr(self.dbus_method, _method_name)(*args, **kwargs)
-		#print("DEBUG: %s.%s result %s" %
-		#	(self.interface, _method_name, str(type(result))))
-
-		if 'RETURN_VALUE' in \
-				self.introspect[self.interface]['methods'][_method_name]:
-			r_type = self.introspect[self.interface]['methods'] \
-				[_method_name]['RETURN_VALUE']['a_type']
+		# print("DEBUG: %s.%s result %s" %
+		# (self.interface, _method_name, str(type(result))))
+
+		if 'RETURN_VALUE' in self.introspect[
+				self.interface]['methods'][_method_name]:
+			r_type = self.introspect[
+				self.interface]['methods'][
+				_method_name]['RETURN_VALUE']['a_type']
 
 			verify_type(result, r_type)
 


