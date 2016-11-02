From: tasleson <tasleson@fedoraproject.org>
Date: Wed,  2 Nov 2016 21:48:02 +0000 (UTC)
Subject: master - lvmdbusd: Don't use dbus lib in worker thread
Message-ID: <20161102214802.2FE4560B20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60de09b00caf034367278adea420b67700c01b71
Commit:        60de09b00caf034367278adea420b67700c01b71
Parent:        38dd79307a51faedb75e092a7913781e6eb88902
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 1 17:52:18 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 2 16:39:03 2016 -0500

lvmdbusd: Don't use dbus lib in worker thread

Simplify the code paths so that we don't utilize the dbus library code
when we are in worker thread context.

ref. https://bugs.freedesktop.org/show_bug.cgi?id=98521
---
 daemons/lvmdbusd/lv.py      |   24 +++++++-----------------
 daemons/lvmdbusd/manager.py |   16 ++++------------
 daemons/lvmdbusd/pv.py      |    6 +++---
 daemons/lvmdbusd/vg.py      |   13 ++-----------
 4 files changed, 16 insertions(+), 43 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index c356799..e130ae4 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -21,7 +21,7 @@ from .utils import n, n32
 from .loader import common
 from .state import State
 from . import background
-from .utils import round_size
+from .utils import round_size, mt_remove_dbus_objects
 from .job import JobState
 
 
@@ -415,7 +415,6 @@ class Lv(LvCommon):
 			rc, out, err = cmdhandler.lv_remove(lv_name, remove_options)
 
 			if rc == 0:
-				cfg.om.remove_object(dbo, True)
 				cfg.load()
 			else:
 				# Need to work on error handling, need consistent
@@ -515,15 +514,9 @@ class Lv(LvCommon):
 			rc, out, err = cmdhandler.vg_lv_snapshot(
 				lv_name, snapshot_options, name, optional_size)
 			if rc == 0:
-				return_path = '/'
+				cfg.load()
 				full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
-				lvs = load_lvs([full_name], emit_signal=True)[0]
-				for l in lvs:
-					return_path = l.dbus_object_path()
-
-				# Refresh self and all included PVs
-				cfg.load(cache_refresh=False)
-				return return_path
+				return cfg.om.get_object_path_by_lvm_id(full_name)
 			else:
 				raise dbus.exceptions.DBusException(
 					LV_INTERFACE,
@@ -752,9 +745,8 @@ class LvThinPool(Lv):
 				lv_name, create_options, name, size_bytes)
 			if rc == 0:
 				full_name = "%s/%s" % (dbo.vg_name_lookup(), name)
-				lvs = load_lvs([full_name], emit_signal=True)[0]
-				for l in lvs:
-					lv_created = l.dbus_object_path()
+				cfg.load()
+				lv_created = cfg.om.get_object_path_by_lvm_id(full_name)
 			else:
 				raise dbus.exceptions.DBusException(
 					LV_INTERFACE,
@@ -816,8 +808,7 @@ class LvCachePool(Lv):
 				# When we cache an LV, the cache pool and the lv that is getting
 				# cached need to be removed from the object manager and
 				# re-created as their interfaces have changed!
-				cfg.om.remove_object(dbo, emit_signal=True)
-				cfg.om.remove_object(lv_to_cache, emit_signal=True)
+				mt_remove_dbus_objects((dbo, lv_to_cache))
 				cfg.load()
 
 				lv_converted = cfg.om.get_object_path_by_lvm_id(fcn)
@@ -879,8 +870,7 @@ class LvCacheLv(Lv):
 			if rc == 0:
 				# The cache pool gets removed as hidden and put back to
 				# visible, so lets delete
-				cfg.om.remove_object(cache_pool, emit_signal=True)
-				cfg.om.remove_object(dbo, emit_signal=True)
+				mt_remove_dbus_objects((cache_pool, dbo))
 				cfg.load()
 
 				uncached_lv_path = cfg.om.get_object_path_by_lvm_id(lv_name)
diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index e377442..e81ee1f 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -42,12 +42,10 @@ class Manager(AutomatedProperties):
 			raise dbus.exceptions.DBusException(
 				MANAGER_INTERFACE, "PV Already exists!")
 
-		created_pv = []
 		rc, out, err = cmdhandler.pv_create(create_options, [device])
 		if rc == 0:
-			pvs = load_pvs([device], emit_signal=True)[0]
-			for p in pvs:
-				created_pv = p.dbus_object_path()
+			cfg.load()
+			created_pv = cfg.om.get_object_path_by_lvm_id(device)
 		else:
 			raise dbus.exceptions.DBusException(
 				MANAGER_INTERFACE,
@@ -80,20 +78,14 @@ class Manager(AutomatedProperties):
 					MANAGER_INTERFACE, 'object path = %s not found' % p)
 
 		rc, out, err = cmdhandler.vg_create(create_options, pv_devices, name)
-		created_vg = "/"
 
 		if rc == 0:
-			vgs = load_vgs([name], emit_signal=True)[0]
-			for v in vgs:
-				created_vg = v.dbus_object_path()
-
-			# Update the PVS
-			load_pvs(refresh=True, emit_signal=True, cache_refresh=False)
+			cfg.load()
+			return cfg.om.get_object_path_by_lvm_id(name)
 		else:
 			raise dbus.exceptions.DBusException(
 				MANAGER_INTERFACE,
 				'Exit code %s, stderr = %s' % (str(rc), err))
-		return created_vg
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,
diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index ad8d8b3..fa07f98 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -18,7 +18,7 @@ from .utils import vg_obj_path_generate, n, pv_obj_path_generate, \
 from .loader import common
 from .request import RequestEntry
 from .state import State
-from .utils import round_size
+from .utils import round_size, mt_remove_dbus_objects
 
 
 # noinspection PyUnusedLocal
@@ -140,7 +140,7 @@ class Pv(AutomatedProperties):
 		if dbo:
 			rc, out, err = cmdhandler.pv_remove(pv_name, remove_options)
 			if rc == 0:
-				cfg.om.remove_object(dbo, True)
+				mt_remove_dbus_objects((dbo,))
 			else:
 				# Need to work on error handling, need consistent
 				raise dbus.exceptions.DBusException(
@@ -174,7 +174,7 @@ class Pv(AutomatedProperties):
 			rc, out, err = cmdhandler.pv_resize(pv_name, new_size_bytes,
 												resize_options)
 			if rc == 0:
-				dbo.refresh()
+				cfg.load()
 			else:
 				raise dbus.exceptions.DBusException(
 					PV_INTERFACE,
diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 70ccad6..d84bb75 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -19,7 +19,7 @@ from .request import RequestEntry
 from .loader import common
 from .state import State
 from . import background
-from .utils import round_size
+from .utils import round_size, mt_remove_dbus_objects
 from .job import JobState
 
 
@@ -191,14 +191,7 @@ class Vg(AutomatedProperties):
 			rc, out, err = cmdhandler.vg_remove(vg_name, remove_options)
 
 			if rc == 0:
-				# Remove the VG
-				cfg.om.remove_object(dbo, True)
-
-				# If an LV has hidden LVs, things can get quite involved,
-				# especially if it's the last thin pool to get removed, so
-				# lets refresh all
 				cfg.load()
-
 			else:
 				# Need to work on error handling, need consistent
 				raise dbus.exceptions.DBusException(
@@ -605,9 +598,7 @@ class Vg(AutomatedProperties):
 			rc, out, err = create_method(
 				md.lv_full_name(), data.lv_full_name(), create_options)
 			if rc == 0:
-				cfg.om.remove_object(md, emit_signal=True)
-				cfg.om.remove_object(data, emit_signal=True)
-
+				mt_remove_dbus_objects((md, data))
 				cache_pool_lv = Vg.fetch_new_lv(vg_name, new_name)
 			else:
 				raise dbus.exceptions.DBusException(


