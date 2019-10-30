From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:54 -0400
Subject: master - lvmdbustest.py: Improve concurrent test handling
Message-ID: <201910301545.x9UFjsSu017030@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f91df163e21b283e652bc830b5af49a7bb3cf3fb
Commit:        f91df163e21b283e652bc830b5af49a7bb3cf3fb
Parent:        f961311436bda50b219f6d2909d8602e37148611
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Oct 14 14:31:27 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Improve concurrent test handling

Filter out LVs too, so that we can run more than 1 instance of the
unit test at the same time.
---
 test/dbus/lvmdbustest.py |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 64a126a..711b247 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -90,6 +90,9 @@ def _root_pv_name(res, pv_name):
 		if v.Vg.Name == vg_name:
 			pv = ClientProxy(bus, v.Vg.Pvs[0], interfaces=(PV_INT, ))
 			return _root_pv_name(res, pv.Pv.Name)
+def _prune_lvs(res, interface, vg_object_path):
+	lvs = [lv for lv in res[interface] if lv.LvCommon.Vg == vg_object_path]
+	res[interface] = lvs
 
 
 def _prune(res, pv_filter):
@@ -106,11 +109,16 @@ def _prune(res, pv_filter):
 
 		vg_list = []
 		for v in res[VG_INT]:
-			# Only need to validate one of the PVs is in the selection set
 			if v.Vg.Pvs[0] in pv_lookup:
 				vg_list.append(v)
 
+				for interface in \
+					[LV_INT, THINPOOL_INT, LV_COMMON_INT,
+						CACHE_POOL_INT, CACHE_LV_INT, VDOPOOL_INT]:
+					_prune_lvs(res, interface, v.object_path)
+
 		res[VG_INT] = vg_list
+
 	return res
 
 
@@ -134,7 +142,7 @@ def get_objects():
 			rc[interface].append(proxy)
 
 	# At this point we have a full population of everything, we now need to
-	# prune the PV list and the VG list if we are using a sub selection
+	# prune the the objects if we are filtering PVs with a sub selection.
 	return _prune(rc, pv_device_list), bus
 
 


