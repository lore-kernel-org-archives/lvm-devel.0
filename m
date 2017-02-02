From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  2 Feb 2017 16:59:22 +0000 (UTC)
Subject: master - lvmdbusd: pv.py, remove duplicate code
Message-ID: <20170202165922.E26606024A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=681d69c70ae70dffa9d21bfd82e1e9821371ee82
Commit:        681d69c70ae70dffa9d21bfd82e1e9821371ee82
Parent:        a010cede6e69fcb9301d0b1f4e282a2b04d15430
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Feb 1 16:51:00 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Feb 1 16:51:00 2017 -0600

lvmdbusd: pv.py, remove duplicate code

Move similar code to common functions, less is more!
---
 daemons/lvmdbusd/pv.py |   65 ++++++++++++++++++-----------------------------
 1 files changed, 25 insertions(+), 40 deletions(-)

diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index 95047d1..fe32143 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -135,23 +135,30 @@ class Pv(AutomatedProperties):
 	def _remove(pv_uuid, pv_name, remove_options):
 		# Remove the PV, if successful then remove from the model
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(pv_uuid, pv_name)
+		Pv.validate_dbus_object(pv_uuid, pv_name)
+		rc, out, err = cmdhandler.pv_remove(pv_name, remove_options)
+		Pv.handle_execute(rc, out, err)
+		return '/'
 
-		if dbo:
-			rc, out, err = cmdhandler.pv_remove(pv_name, remove_options)
-			if rc == 0:
-				cfg.load()
-			else:
-				# Need to work on error handling, need consistent
-				raise dbus.exceptions.DBusException(
-					PV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
+	@staticmethod
+	def handle_execute(rc, out, err):
+		if rc == 0:
+			cfg.load()
 		else:
+			# Need to work on error handling, need consistent
+			raise dbus.exceptions.DBusException(
+				PV_INTERFACE,
+				'Exit code %s, stderr = %s' % (str(rc), err))
+
+	@staticmethod
+	def validate_dbus_object(pv_uuid, pv_name):
+		dbo = cfg.om.get_object_by_uuid_lvm_id(pv_uuid, pv_name)
+		if not dbo:
 			raise dbus.exceptions.DBusException(
 				PV_INTERFACE,
 				'PV with uuid %s and name %s not present!' %
 				(pv_uuid, pv_name))
-		return '/'
+		return dbo
 
 	@dbus.service.method(
 		dbus_interface=PV_INTERFACE,
@@ -168,22 +175,11 @@ class Pv(AutomatedProperties):
 	@staticmethod
 	def _resize(pv_uuid, pv_name, new_size_bytes, resize_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(pv_uuid, pv_name)
+		Pv.validate_dbus_object(pv_uuid, pv_name)
 
-		if dbo:
-			rc, out, err = cmdhandler.pv_resize(pv_name, new_size_bytes,
+		rc, out, err = cmdhandler.pv_resize(pv_name, new_size_bytes,
 												resize_options)
-			if rc == 0:
-				cfg.load()
-			else:
-				raise dbus.exceptions.DBusException(
-					PV_INTERFACE,
-					'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				PV_INTERFACE,
-				'PV with uuid %s and name %s not present!' %
-				(pv_uuid, pv_name))
+		Pv.handle_execute(rc, out, err)
 		return '/'
 
 	@dbus.service.method(
@@ -201,21 +197,10 @@ class Pv(AutomatedProperties):
 	@staticmethod
 	def _allocation_enabled(pv_uuid, pv_name, yes_no, allocation_options):
 		# Make sure we have a dbus object representing it
-		dbo = cfg.om.get_object_by_uuid_lvm_id(pv_uuid, pv_name)
-
-		if dbo:
-			rc, out, err = cmdhandler.pv_allocatable(
-				pv_name, yes_no, allocation_options)
-			if rc == 0:
-				cfg.load()
-			else:
-				raise dbus.exceptions.DBusException(
-					PV_INTERFACE, 'Exit code %s, stderr = %s' % (str(rc), err))
-		else:
-			raise dbus.exceptions.DBusException(
-				PV_INTERFACE,
-				'PV with uuid %s and name %s not present!' %
-				(pv_uuid, pv_name))
+		Pv.validate_dbus_object(pv_uuid, pv_name)
+		rc, out, err = cmdhandler.pv_allocatable(
+			pv_name, yes_no, allocation_options)
+		Pv.handle_execute(rc, out, err)
 		return '/'
 
 	@dbus.service.method(


