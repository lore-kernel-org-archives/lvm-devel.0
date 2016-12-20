From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 20 Dec 2016 17:08:20 +0000 (UTC)
Subject: master - lvmdbustest: Print messages if timeout value > 10%
Message-ID: <20161220170820.F23F860E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eacff5c189d0cb3c6ac17a8f0af0fe440f12c4b7
Commit:        eacff5c189d0cb3c6ac17a8f0af0fe440f12c4b7
Parent:        a7e1f973ccd1abfc0f868f0b9c2382c2034e1633
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Dec 14 15:32:08 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Dec 20 11:06:57 2016 -0600

lvmdbustest: Print messages if timeout value > 10%

We will dump some informational messages if the time to return when we
specify a timeout exceeds 10% of requested.
---
 test/dbus/testlib.py |   25 ++++++++++++++++++++++---
 1 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 89e73d2..34ff33a 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -16,6 +16,7 @@ from collections import OrderedDict
 import dbus
 import os
 import sys
+import time
 
 BUS_NAME = os.getenv('LVM_DBUS_NAME', 'com.redhat.lvmdbus1')
 BASE_INTERFACE = 'com.redhat.lvmdbus1'
@@ -188,10 +189,15 @@ class RemoteInterface(object):
 
 	def __init__(
 			self, dbus_object, interface, introspect,
-			properties=None):
+			properties=None, timelimit=-1):
 		self.dbus_object = dbus_object
 		self.interface = interface
 		self.introspect = introspect
+		self.tmo = 0
+
+		if timelimit >= 0:
+			self.tmo = float(timelimit)
+			self.tmo *= 1.10
 
 		self.dbus_interface = dbus.Interface(self.dbus_object, self.interface)
 		self._set_props(properties)
@@ -203,7 +209,19 @@ class RemoteInterface(object):
 			return functools.partial(self, item)
 
 	def _wrapper(self, _method_name, *args, **kwargs):
+
+		# Lets see how long a method takes to execute, in call cases we should
+		# return something when the time limit has been reached.
+		start = time.time()
 		result = getattr(self.dbus_interface, _method_name)(*args, **kwargs)
+		end = time.time()
+
+		diff = end - start
+
+		if self.tmo > 0.0:
+			if diff > self.tmo:
+				std_err_print("\n Time exceeded: %f > %f %s" %
+								(diff, self.tmo, _method_name))
 
 		if self.introspect:
 			if 'RETURN_VALUE' in self.introspect[
@@ -236,13 +254,14 @@ class ClientProxy(object):
 		short_name = ClientProxy._intf_short_name(interface)
 		self.short_interface_names.append(short_name)
 		ro = RemoteInterface(self.dbus_object, interface, introspect,
-								properties)
+								properties, timelimit=self.tmo)
 		setattr(self, short_name, ro)
 
 	def __init__(self, bus, object_path, interface_prop_hash=None,
-					interfaces=None):
+					interfaces=None, timelimit=-1):
 		self.object_path = object_path
 		self.short_interface_names = []
+		self.tmo = timelimit
 		self.dbus_object = bus.get_object(
 			BUS_NAME, self.object_path, introspect=False)
 


