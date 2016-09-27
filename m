From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 27 Sep 2016 18:33:50 +0000 (UTC)
Subject: master - lvmdbusd: Allow PV device names to be '[unknown]'
Message-ID: <20160927183350.7A74E60D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=063265eacda95dbc1567e647734a000c8d68c8b7
Commit:        063265eacda95dbc1567e647734a000c8d68c8b7
Parent:        a882eb2b3b6eba6a482d4dcb1079a3ffa615fb6a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 26 22:02:08 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Sep 27 13:28:54 2016 -0500

lvmdbusd: Allow PV device names to be '[unknown]'

When a PV device is missing lvm will return '[unknown]' for the device
path.  The object manager keeps a hash table lookup for uuid and for PV's
device name.  When we had multiple PVs with the same device path we
we only had 1 key in the table for the lvm id (device path).  This caused
a problem when the PV device transitioned from '[unknown]' to known as any
subsequent transitions would cause an exception:

Traceback (most recent call last):
  File "/usr/lib/python3.5/site-packages/lvmdbusd/request.py", line 66, in run_cmd
    result = self.method(*self.arguments)
  File "/usr/lib/python3.5/site-packages/lvmdbusd/manager.py", line 205, in _pv_scan
    cfg.load()
  File "/usr/lib/python3.5/site-packages/lvmdbusd/fetch.py", line 24, in load
    cache_refresh=False)[1]
  File "/usr/lib/python3.5/site-packages/lvmdbusd/pv.py", line 48, in load_pvs
    emit_signal, cache_refresh)
  File "/usr/lib/python3.5/site-packages/lvmdbusd/loader.py", line 80, in common
    cfg.om.remove_object(cfg.om.get_object_by_path(k), True)
  File "/usr/lib/python3.5/site-packages/lvmdbusd/objectmanager.py", line 153, in remove_object
    self._lookup_remove(path)
  File "/usr/lib/python3.5/site-packages/lvmdbusd/objectmanager.py", line 97, in _lookup_remove
    del self._id_to_object_path[lvm_id]
KeyError: '[unknown]'

when trying to delete a key that wasn't present.  In this case we don't add a
lookup key for the device path and the PV can only be located by UUID.

Ref: https://bugzilla.redhat.com/show_bug.cgi?id=1379357
---
 daemons/lvmdbusd/objectmanager.py |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index 55f1729..f491df4 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -13,7 +13,7 @@ import traceback
 import dbus
 import os
 from . import cfg
-from .utils import log_debug
+from .utils import log_debug, pv_obj_path_generate
 from .automatedproperties import AutomatedProperties
 
 
@@ -75,7 +75,7 @@ class ObjectManager(AutomatedProperties):
 		Store information about what we added to the caches so that we
 		can remove it cleanly
 		:param obj:     The dbus object we are storing
-		:param lvm_id:  The user name for the asset
+		:param lvm_id:  The lvm id for the asset
 		:param uuid:    The uuid for the asset
 		:return:
 		"""
@@ -85,7 +85,12 @@ class ObjectManager(AutomatedProperties):
 		self._lookup_remove(path)
 
 		self._objects[path] = (obj, lvm_id, uuid)
-		self._id_to_object_path[lvm_id] = path
+
+		# Make sure we have one or the other
+		assert lvm_id or uuid
+
+		if lvm_id:
+			self._id_to_object_path[lvm_id] = path
 
 		if uuid:
 			self._id_to_object_path[uuid] = path
@@ -94,8 +99,13 @@ class ObjectManager(AutomatedProperties):
 		# Note: Only called internally, lock implied
 		if obj_path in self._objects:
 			(obj, lvm_id, uuid) = self._objects[obj_path]
-			del self._id_to_object_path[lvm_id]
-			del self._id_to_object_path[uuid]
+
+			if lvm_id in self._id_to_object_path:
+				del self._id_to_object_path[lvm_id]
+
+			if uuid in self._id_to_object_path:
+				del self._id_to_object_path[uuid]
+
 			del self._objects[obj_path]
 
 	def lookup_update(self, dbus_obj, new_uuid, new_lvm_id):
@@ -206,7 +216,8 @@ class ObjectManager(AutomatedProperties):
 		:return: None
 		"""
 		# This gets called when we found an object based on lvm_id, ensure
-		# uuid is correct too, as they can change
+		# uuid is correct too, as they can change. There is no durable
+		# non-changeable name in lvm
 		if lvm_id != uuid:
 			if uuid and uuid not in self._id_to_object_path:
 				obj = self.get_object_by_path(path)
@@ -221,12 +232,14 @@ class ObjectManager(AutomatedProperties):
 		:param lvm_id:		lvm_id to verify
 		:return: None
 		"""
-		# This gets called when we found an object based on lvm_id, ensure
-		# uuid is correct too, as they can change
+		# This gets called when we found an object based on uuid, ensure
+		# lvm_id is correct too, as they can change.  There is no durable
+		# non-changeable name in lvm
 		if lvm_id != uuid:
 			if lvm_id and lvm_id not in self._id_to_object_path:
 				obj = self.get_object_by_path(path)
 				self._lookup_add(obj, path, lvm_id, uuid)
+
 	def _id_lookup(self, the_id):
 		path = None
 
@@ -277,6 +290,12 @@ class ObjectManager(AutomatedProperties):
 				# We have a uuid and a lvm_id we can do sanity checks to ensure
 				# that they are consistent
 
+				# If a PV is missing it's device path is '[unknown]'.  When
+				# we see the lvm_id as such we will re-assign to None
+				if path_create == pv_obj_path_generate and \
+						lvm_id == '[unknown]':
+					lvm_id = None
+
 				# Lets check for the uuid first
 				path = self._id_lookup(uuid)
 				if path:


