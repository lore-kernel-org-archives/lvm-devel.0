From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  2 Feb 2017 16:59:27 +0000 (UTC)
Subject: master - lvmdbusd: manager.py, remove duplicate code
Message-ID: <20170202165927.127256024A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3eccbb4b4713f0d79831e7c146851bff820c94bb
Commit:        3eccbb4b4713f0d79831e7c146851bff820c94bb
Parent:        945842fa680d6c967b64362fe8b2ce6c3334a52d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Feb 1 18:57:01 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Feb 1 18:57:01 2017 -0600

lvmdbusd: manager.py, remove duplicate code

Move similar code to common functions, less is more!
---
 daemons/lvmdbusd/manager.py |   42 ++++++++++++++++--------------------------
 1 files changed, 16 insertions(+), 26 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 3f6f09b..41bb22a 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -31,6 +31,16 @@ class Manager(AutomatedProperties):
 		return dbus.String('1.0.0')
 
 	@staticmethod
+	def handle_execute(rc, out, err):
+		if rc == 0:
+			cfg.load()
+		else:
+			# Need to work on error handling, need consistent
+			raise dbus.exceptions.DBusException(
+				MANAGER_INTERFACE,
+				'Exit code %s, stderr = %s' % (str(rc), err))
+
+	@staticmethod
 	def _pv_create(device, create_options):
 
 		# Check to see if we are already trying to create a PV for an existing
@@ -41,15 +51,8 @@ class Manager(AutomatedProperties):
 				MANAGER_INTERFACE, "PV Already exists!")
 
 		rc, out, err = cmdhandler.pv_create(create_options, [device])
-		if rc == 0:
-			cfg.load()
-			created_pv = cfg.om.get_object_path_by_lvm_id(device)
-		else:
-			raise dbus.exceptions.DBusException(
-				MANAGER_INTERFACE,
-				'Exit code %s, stderr = %s' % (str(rc), err))
-
-		return created_pv
+		Manager.handle_execute(rc, out, err)
+		return cfg.om.get_object_path_by_lvm_id(device)
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
@@ -76,14 +79,8 @@ class Manager(AutomatedProperties):
 					MANAGER_INTERFACE, 'object path = %s not found' % p)
 
 		rc, out, err = cmdhandler.vg_create(create_options, pv_devices, name)
-
-		if rc == 0:
-			cfg.load()
-			return cfg.om.get_object_path_by_lvm_id(name)
-		else:
-			raise dbus.exceptions.DBusException(
-				MANAGER_INTERFACE,
-				'Exit code %s, stderr = %s' % (str(rc), err))
+		Manager.handle_execute(rc, out, err)
+		return cfg.om.get_object_path_by_lvm_id(name)
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
@@ -200,15 +197,8 @@ class Manager(AutomatedProperties):
 			activate, cache, device_path,
 			major_minor, scan_options)
 
-		if rc == 0:
-			# This could potentially change the state quite a bit, so lets
-			# update everything to be safe
-			cfg.load()
-			return '/'
-		else:
-			raise dbus.exceptions.DBusException(
-				MANAGER_INTERFACE,
-				'Exit code %s, stderr = %s' % (str(rc), err))
+		Manager.handle_execute(rc, out, err)
+		return '/'
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,


