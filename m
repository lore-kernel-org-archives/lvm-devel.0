From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 21 Mar 2016 22:33:59 +0000 (UTC)
Subject: master - lvmdbusd: Allow PV devices to be referenced by symlink(s)
Message-ID: <20160321223359.E65986072A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0c7875c547fb8a420d789271f5e6660210e749f
Commit:        a0c7875c547fb8a420d789271f5e6660210e749f
Parent:        86e9d12b6f06c741ada66cd417f3fa82ea0364b6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Mar 21 17:19:38 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Mar 21 17:28:51 2016 -0500

lvmdbusd: Allow PV devices to be referenced by symlink(s)

See: https://bugzilla.redhat.com/show_bug.cgi?id=1318754

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/lvmdb.py         |    6 ++++++
 daemons/lvmdbusd/objectmanager.py |   31 +++++++++++++++++++++++--------
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index 132bee7..be37868 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -12,6 +12,7 @@
 from collections import OrderedDict
 
 import pprint as prettyprint
+import os
 
 try:
 	from . import cmdhandler
@@ -309,6 +310,11 @@ class DataStore(object):
 		else:
 			rc = []
 			for s in pv_name:
+				# Ths user could be using a symlink instead of the actual
+				# block device, make sure we are using actual block device file
+				# if the pv name isn't in the lookup
+				if s not in self.pv_path_to_uuid:
+					s = os.path.realpath(s)
 				rc.append(self.pvs[self.pv_path_to_uuid[s]])
 			return rc
 
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index e2f1e0a..f28c5c8 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -11,6 +11,7 @@ import sys
 import threading
 import traceback
 import dbus
+import os
 from . import cfg
 from .utils import log_debug
 from .automatedproperties import AutomatedProperties
@@ -184,13 +185,13 @@ class ObjectManager(AutomatedProperties):
 				return self.get_object_by_path(self._id_to_object_path[lvm_id])
 			return None
 
-	def _uuid_verify(self, path, lvm_id, uuid):
+	def _uuid_verify(self, path, uuid, lvm_id):
 		"""
 		Ensure uuid is present for a successful lvm_id lookup
 		NOTE: Internal call, assumes under object manager lock
 		:param path: 		Path to object we looked up
-		:param lvm_id:		lvm_id used to find object
 		:param uuid: 		lvm uuid to verify
+		:param lvm_id:		lvm_id used to find object
 		:return: None
 		"""
 		# This gets called when we found an object based on lvm_id, ensure
@@ -200,6 +201,17 @@ class ObjectManager(AutomatedProperties):
 				obj = self.get_object_by_path(path)
 				self._lookup_add(obj, path, lvm_id, uuid)
 
+	def _return_lookup(self, uuid, lvm_identifier):
+		"""
+		We found an identifier, so lets return the path to the found object
+		:param uuid:	The lvm uuid
+		:param lvm_identifier: The lvm_id used to find object
+		:return:
+		"""
+		path = self._id_to_object_path[lvm_identifier]
+		self._uuid_verify(path, uuid, lvm_identifier)
+		return path
+
 	def get_object_path_by_lvm_id(self, uuid, lvm_id, path_create=None,
 								gen_new=True):
 		"""
@@ -221,16 +233,19 @@ class ObjectManager(AutomatedProperties):
 			path = None
 
 			if lvm_id in self._id_to_object_path:
-				path = self._id_to_object_path[lvm_id]
-				self._uuid_verify(path, lvm_id, uuid)
-				return path
+				self._return_lookup(uuid, lvm_id)
+
 			if "/" in lvm_id:
 				vg, lv = lvm_id.split("/", 1)
 				int_lvm_id = vg + "/" + ("[%s]" % lv)
 				if int_lvm_id in self._id_to_object_path:
-					path = self._id_to_object_path[int_lvm_id]
-					self._uuid_verify(path, int_lvm_id, uuid)
-					return path
+					self._return_lookup(uuid, int_lvm_id)
+				elif lvm_id.startswith('/'):
+					# We could have a pv device path lookup that failed,
+					# lets try canonical form and try again.
+					canonical = os.path.realpath(lvm_id)
+					if canonical in self._id_to_object_path:
+						self._return_lookup(uuid, canonical)
 
 			if uuid and uuid in self._id_to_object_path:
 				# If we get here it indicates that we found the object, but


