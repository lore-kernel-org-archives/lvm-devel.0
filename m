From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jan 2019 17:33:04 -0500
Subject: master - lvmdbusd: Correct object manager lookups
Message-ID: <201901162233.x0GMX4cC027561@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b4c33829908015acc6ce0690ee5d33c1eb87e98e
Commit:        b4c33829908015acc6ce0690ee5d33c1eb87e98e
Parent:        1ed4b3f23baf13e224d0c24735304f872c0930e8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Jan 16 15:27:55 2019 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jan 16 16:29:05 2019 -0600

lvmdbusd: Correct object manager lookups

When we have two logical volumes which switch their names at the
same time we are left with incorrect lookups.  Anytime we find
an entry by doing a lookup by UUID or by name we will ensure
that the lookups are indeed correct.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1642176
---
 daemons/lvmdbusd/objectmanager.py |   50 +++++++++++-------------------------
 1 files changed, 15 insertions(+), 35 deletions(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index 563b9ec..e40e9a1 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -189,8 +189,8 @@ class ObjectManager(AutomatedProperties):
 			path = dbus_object.dbus_object_path()
 			interfaces = dbus_object.interface()
 
-			# print 'UN-Registering object path %s for %s' % \
-			#      (path, dbus_object.lvm_id)
+			# print('UN-Registering object path %s for %s' %
+			#		(path, dbus_object.lvm_id))
 
 			self._lookup_remove(path)
 
@@ -240,39 +240,19 @@ class ObjectManager(AutomatedProperties):
 				return lookup_rc
 			return '/'
 
-	def _uuid_verify(self, path, uuid, lvm_id):
+	def _id_verify(self, path, uuid, lvm_id):
 		"""
-		Ensure uuid is present for a successful lvm_id lookup
+		Ensure our lookups are correct
 		NOTE: Internal call, assumes under object manager lock
 		:param path: 		Path to object we looked up
-		:param uuid: 		lvm uuid to verify
-		:param lvm_id:		lvm_id used to find object
+		:param uuid: 		uuid lookup
+		:param lvm_id:		lvm_id lookup
 		:return: None
 		"""
-		# This gets called when we found an object based on lvm_id, ensure
-		# uuid is correct too, as they can change. There is no durable
-		# non-changeable name in lvm
+		# There is no durable non-changeable name in lvm
 		if lvm_id != uuid:
-			if uuid and uuid not in self._id_to_object_path:
-				obj = self.get_object_by_path(path)
-				self._lookup_add(obj, path, lvm_id, uuid)
-
-	def _lvm_id_verify(self, path, uuid, lvm_id):
-		"""
-		Ensure lvm_id is present for a successful uuid lookup
-		NOTE: Internal call, assumes under object manager lock
-		:param path: 		Path to object we looked up
-		:param uuid: 		uuid used to find object
-		:param lvm_id:		lvm_id to verify
-		:return: None
-		"""
-		# This gets called when we found an object based on uuid, ensure
-		# lvm_id is correct too, as they can change.  There is no durable
-		# non-changeable name in lvm
-		if lvm_id != uuid:
-			if lvm_id and lvm_id not in self._id_to_object_path:
-				obj = self.get_object_by_path(path)
-				self._lookup_add(obj, path, lvm_id, uuid)
+			obj = self.get_object_by_path(path)
+			self._lookup_add(obj, path, lvm_id, uuid)
 
 	def _id_lookup(self, the_id):
 		path = None
@@ -339,22 +319,22 @@ class ObjectManager(AutomatedProperties):
 				# Lets check for the uuid first
 				path = self._id_lookup(uuid)
 				if path:
-					# Verify the lvm_id is sane
-					self._lvm_id_verify(path, uuid, lvm_id)
+					# Ensure table lookups are correct
+					self._id_verify(path, uuid, lvm_id)
 				else:
 					# Unable to find by UUID, lets lookup by lvm_id
 					path = self._id_lookup(lvm_id)
 					if path:
-						# Verify the uuid is sane
-						self._uuid_verify(path, uuid, lvm_id)
+						# Ensure table lookups are correct
+						self._id_verify(path, uuid, lvm_id)
 					else:
 						# We have exhausted all lookups, let's create if we can
 						if path_create:
 							path = path_create()
 							self._lookup_add(None, path, lvm_id, uuid)
 
-			# print('get_object_path_by_lvm_id(%s, %s, %s, %s: return %s' %
-			# 	   (uuid, lvm_id, str(path_create), str(gen_new), path))
+			# print('get_object_path_by_lvm_id(%s, %s, %s): return %s' %
+			#	(uuid, lvm_id, str(path_create), path))
 
 			return path
 


