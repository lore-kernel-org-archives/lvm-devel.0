From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 27 Sep 2016 18:33:54 +0000 (UTC)
Subject: master - lvmdbusd: Add diagnostic validate for look ups
Message-ID: <20160927183354.C2EDA60D9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a93616cf66b15591f741dc5f1450c12bc34b3785
Commit:        a93616cf66b15591f741dc5f1450c12bc34b3785
Parent:        d906fd520129d639c7cad27c24f88836d133f9ad
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Sep 27 10:08:23 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Sep 27 13:28:54 2016 -0500

lvmdbusd: Add diagnostic validate for look ups

Make sure that the lookup tables don't have extranoues stuff in
them.
---
 daemons/lvmdbusd/manager.py       |    6 +++++-
 daemons/lvmdbusd/objectmanager.py |   28 +++++++++++++++++++++++++++-
 2 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index b7d7b10..0a5fe73 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -115,6 +115,10 @@ class Manager(AutomatedProperties):
 
 		# This is a diagnostic and should not be run in normal operation, so
 		# lets remove the log entries for refresh as it's implied.
+
+		# Run an internal diagnostic on the object manager look up tables
+		lc = cfg.om.validate_lookups()
+
 		rc = cfg.load(log=False)
 
 		if rc != 0:
@@ -122,7 +126,7 @@ class Manager(AutomatedProperties):
 							'bg_black', 'fg_light_red')
 		else:
 			utils.log_debug('Manager.Refresh - exit %d' % (rc))
-		return rc
+		return rc + lc
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
diff --git a/daemons/lvmdbusd/objectmanager.py b/daemons/lvmdbusd/objectmanager.py
index f491df4..d55ca99 100644
--- a/daemons/lvmdbusd/objectmanager.py
+++ b/daemons/lvmdbusd/objectmanager.py
@@ -12,8 +12,9 @@ import threading
 import traceback
 import dbus
 import os
+import copy
 from . import cfg
-from .utils import log_debug, pv_obj_path_generate
+from .utils import log_debug, pv_obj_path_generate, log_error
 from .automatedproperties import AutomatedProperties
 
 
@@ -70,6 +71,31 @@ class ObjectManager(AutomatedProperties):
 		log_debug(('SIGNAL: InterfacesRemoved(%s, %s)' %
 			(str(object_path), str(interface_list))))
 
+	def validate_lookups(self):
+		with self.rlock:
+			tmp_lookups = copy.deepcopy(self._id_to_object_path)
+
+			# iterate over all we know, removing from the copy.  If all is well
+			# we will have zero items left over
+			for path, md in self._objects.items():
+				obj, lvm_id, uuid = md
+
+				if lvm_id:
+					assert path == tmp_lookups[lvm_id]
+					del tmp_lookups[lvm_id]
+
+				if uuid:
+					assert path == tmp_lookups[uuid]
+					del tmp_lookups[uuid]
+
+			rc = len(tmp_lookups)
+			if rc:
+				# Error condition
+				log_error("_id_to_object_path has extraneous lookups!")
+				for key, path in tmp_lookups.items():
+					log_error("Key= %s, path= %s" % (key, path))
+		return rc
+
 	def _lookup_add(self, obj, path, lvm_id, uuid):
 		"""
 		Store information about what we added to the caches so that we


