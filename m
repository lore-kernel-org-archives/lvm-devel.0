From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 27 Sep 2016 18:33:48 +0000 (UTC)
Subject: master - lvmdbusd: Clean up objectmanager.get_object_path_by_uuid_lvm_id
Message-ID: <20160927183348.647F760D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a882eb2b3b6eba6a482d4dcb1079a3ffa615fb6a
Commit:        a882eb2b3b6eba6a482d4dcb1079a3ffa615fb6a
Parent:        ec076b1df239dff91377a6e19ea76a4047b04b32
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 26 21:56:11 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Sep 27 13:28:54 2016 -0500

lvmdbusd: Clean up objectmanager.get_object_path_by_uuid_lvm_id

This method grew crufty with a number of stuble bugs.  Refactor and
simplify.
---
 daemons/lvmdbusd/objectmanager.py |  106 +++++++++++++++++++++---------------
 1 files changed, 62 insertions(+), 44 deletions(-)

diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index 0b810d8..55f1729 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -208,19 +208,46 @@ class ObjectManager(AutomatedProperties):
 		# This gets called when we found an object based on lvm_id, ensure
 		# uuid is correct too, as they can change
 		if lvm_id != uuid:
-			if uuid not in self._id_to_object_path:
+			if uuid and uuid not in self._id_to_object_path:
 				obj = self.get_object_by_path(path)
 				self._lookup_add(obj, path, lvm_id, uuid)
 
-	def _return_lookup(self, uuid, lvm_identifier):
+	def _lvm_id_verify(self, path, uuid, lvm_id):
 		"""
-		We found an identifier, so lets return the path to the found object
-		:param uuid:	The lvm uuid
-		:param lvm_identifier: The lvm_id used to find object
-		:return:
+		Ensure lvm_id is present for a successful uuid lookup
+		NOTE: Internal call, assumes under object manager lock
+		:param path: 		Path to object we looked up
+		:param uuid: 		uuid used to find object
+		:param lvm_id:		lvm_id to verify
+		:return: None
 		"""
-		path = self._id_to_object_path[lvm_identifier]
-		self._uuid_verify(path, uuid, lvm_identifier)
+		# This gets called when we found an object based on lvm_id, ensure
+		# uuid is correct too, as they can change
+		if lvm_id != uuid:
+			if lvm_id and lvm_id not in self._id_to_object_path:
+				obj = self.get_object_by_path(path)
+				self._lookup_add(obj, path, lvm_id, uuid)
+	def _id_lookup(self, the_id):
+		path = None
+
+		if the_id:
+			# The _id_to_object_path contains hash keys for everything, so
+			# uuid and lvm_id
+			if the_id in self._id_to_object_path:
+				path = self._id_to_object_path[the_id]
+			else:
+				if "/" in the_id:
+					if the_id.startswith('/'):
+						# We could have a pv device path lookup that failed,
+						# lets try canonical form and try again.
+						canonical = os.path.realpath(the_id)
+						if canonical in self._id_to_object_path:
+							path = self._id_to_object_path[canonical]
+					else:
+						vg, lv = the_id.split("/", 1)
+						int_lvm_id = vg + "/" + ("[%s]" % lv)
+						if int_lvm_id in self._id_to_object_path:
+							path = self._id_to_object_path[int_lvm_id]
 		return path
 
 	def get_object_path_by_uuid_lvm_id(self, uuid, lvm_id, path_create=None,
@@ -240,44 +267,35 @@ class ObjectManager(AutomatedProperties):
 
 			if gen_new:
 				assert path_create
+				assert uuid != lvm_id
 
-			path = None
-
-			if lvm_id in self._id_to_object_path:
-				self._return_lookup(uuid, lvm_id)
-
-			if "/" in lvm_id:
-				vg, lv = lvm_id.split("/", 1)
-				int_lvm_id = vg + "/" + ("[%s]" % lv)
-				if int_lvm_id in self._id_to_object_path:
-					self._return_lookup(uuid, int_lvm_id)
-				elif lvm_id.startswith('/'):
-					# We could have a pv device path lookup that failed,
-					# lets try canonical form and try again.
-					canonical = os.path.realpath(lvm_id)
-					if canonical in self._id_to_object_path:
-						self._return_lookup(uuid, canonical)
-
-			if uuid and uuid in self._id_to_object_path:
-				# If we get here it indicates that we found the object, but
-				# the lvm_id lookup failed.  In the case of a rename, the uuid
-				# will be correct, but the lvm_id will be wrong and vise versa.
-				# If the lvm_id does not equal the uuid, lets fix up the table
-				# so that lookups will be handled correctly.
-				path = self._id_to_object_path[uuid]
-
-				# In some cases we are looking up by one or the other, don't
-				# update when they are the same.
-				if uuid != lvm_id:
-					obj = self.get_object_by_path(path)
-					self._lookup_add(obj, path, lvm_id, uuid)
+			# Check for Manager.LookUpByLvmId query, we cannot
+			# check/verify/update the uuid and lvm_id lookups so don't!
+			if uuid == lvm_id:
+				path = self._id_lookup(lvm_id)
 			else:
-				if gen_new:
-					path = path_create()
-					self._lookup_add(None, path, lvm_id, uuid)
-
-			# pprint('get_object_path_by_lvm_id(%s, %s, %s, %s: return %s' %
-			#       (uuid, lvm_id, str(path_create), str(gen_new), path))
+				# We have a uuid and a lvm_id we can do sanity checks to ensure
+				# that they are consistent
+
+				# Lets check for the uuid first
+				path = self._id_lookup(uuid)
+				if path:
+					# Verify the lvm_id is sane
+					self._lvm_id_verify(path, uuid, lvm_id)
+				else:
+					# Unable to find by UUID, lets lookup by lvm_id
+					path = self._id_lookup(lvm_id)
+					if path:
+						# Verify the uuid is sane
+						self._uuid_verify(path, uuid, lvm_id)
+					else:
+						# We have exhausted all lookups, let's create if we can
+						if gen_new:
+							path = path_create()
+							self._lookup_add(None, path, lvm_id, uuid)
+
+			# print('get_object_path_by_lvm_id(%s, %s, %s, %s: return %s' %
+			# 	   (uuid, lvm_id, str(path_create), str(gen_new), path))
 
 			return path
 


