From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:53 +0000 (UTC)
Subject: master - lvmdbustest: Move std_err_print to testlib
Message-ID: <20161117173653.012E660C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bfedeb748149c61caab44957c0a4f54fe57d6823
Commit:        bfedeb748149c61caab44957c0a4f54fe57d6823
Parent:        99806ec7ec88c8cade16838ff1c9155fcc861b7e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 17 10:32:55 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbustest: Move std_err_print to testlib

So we can re-use it in the testlib too.
---
 test/dbus/lvmdbustest.py |    9 ++-------
 test/dbus/testlib.py     |    6 ++++++
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index c1cfb0f..8b5c4fd 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -14,10 +14,10 @@ import dbus
 # noinspection PyUnresolvedReferences
 from dbus.mainloop.glib import DBusGMainLoop
 import unittest
-import sys
 import time
 import pyudev
 from testlib import *
+import testlib
 
 g_tmo = 0
 
@@ -44,12 +44,7 @@ else:
 # validation to limit the massive amount of introspection calls we make as
 # that method prevents things from executing concurrently
 if pv_device_list:
-	validate_introspection = False
-
-
-def std_err_print(*args):
-	sys.stderr.write(' '.join(map(str, args)) + '\n')
-	sys.stderr.flush()
+	testlib.validate_introspection = False
 
 
 def vg_n():
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index de61361..e0c26a8 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -15,6 +15,7 @@ import xml.etree.ElementTree as Et
 from collections import OrderedDict
 import dbus
 import os
+import sys
 
 BUS_NAME = os.getenv('LVM_DBUS_NAME', 'com.redhat.lvmdbus1')
 BASE_INTERFACE = 'com.redhat.lvmdbus1'
@@ -43,6 +44,11 @@ def mib(s):
 	return 1024 * 1024 * s
 
 
+def std_err_print(*args):
+	sys.stderr.write(' '.join(map(str, args)) + '\n')
+	sys.stderr.flush()
+
+
 class DbusIntrospection(object):
 	@staticmethod
 	def introspect(xml_representation):


