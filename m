From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:57 -0400
Subject: master - lvmdbustest.py: Use local data instead of fetching
Message-ID: <201910301545.x9UFjv1x017042@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=508d1808b07f204ca0ce71d4d505ded82f30d0ce
Commit:        508d1808b07f204ca0ce71d4d505ded82f30d0ce
Parent:        f91df163e21b283e652bc830b5af49a7bb3cf3fb
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Oct 14 14:33:16 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbustest.py: Use local data instead of fetching

Avoid making more dbus calls to get information we already have.  This
also avoids us getting an error where a dbus object representation is
being deleted by another process while we are trying to gather information
about it across the wire.
---
 test/dbus/lvmdbustest.py |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 711b247..522e3ca 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -88,8 +88,12 @@ def _root_pv_name(res, pv_name):
 	vg_name = pv_name.split('/')[2]
 	for v in res[VG_INT]:
 		if v.Vg.Name == vg_name:
-			pv = ClientProxy(bus, v.Vg.Pvs[0], interfaces=(PV_INT, ))
-			return _root_pv_name(res, pv.Pv.Name)
+			for pv in res[PV_INT]:
+				if pv.object_path in v.Vg.Pvs:
+					return _root_pv_name(res, pv.Pv.Name)
+			return None
+
+
 def _prune_lvs(res, interface, vg_object_path):
 	lvs = [lv for lv in res[interface] if lv.LvCommon.Vg == vg_object_path]
 	res[interface] = lvs


