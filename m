From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:47 +0000 (UTC)
Subject: master - lvmdbusd: Be more specific on return types for Lv
Message-ID: <20160829202847.16D166051E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20318e4c6c389b5ee25b8897fb93aaa036878a95
Commit:        20318e4c6c389b5ee25b8897fb93aaa036878a95
Parent:        9aed18a57167451b20fa67a80052d39634447064
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 12:32:20 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

lvmdbusd: Be more specific on return types for Lv

---
 daemons/lvmdbusd/lv.py |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 6d994ac..3d0b78c 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -103,7 +103,14 @@ class LvState(State):
 			(pv_uuid, pv_name, pv_segs) = pv
 			pv_obj = cfg.om.get_object_path_by_uuid_lvm_id(
 				pv_uuid, pv_name, gen_new=False)
-			rc.append((pv_obj, pv_segs))
+
+			segs_decorate = []
+			for i in pv_segs:
+				segs_decorate.append((dbus.UInt64(i[0]),
+									dbus.UInt64(i[1]),
+									dbus.String(i[2])))
+
+			rc.append((dbus.ObjectPath(pv_obj), segs_decorate))
 
 		return dbus.Array(rc, signature="(oa(tts))")
 
@@ -127,7 +134,7 @@ class LvState(State):
 			op = cfg.om.get_object_path_by_uuid_lvm_id(
 				l[0], full_name, gen_new=False)
 			assert op
-			rc.append(op)
+			rc.append(dbus.ObjectPath(op))
 		return rc
 
 	def __init__(self, Uuid, Name, Path, SizeBytes,
@@ -140,9 +147,9 @@ class LvState(State):
 		# value
 		self._segs = dbus.Array([], signature='s')
 		if not isinstance(segtypes, list):
-			self._segs.append(segtypes)
+			self._segs.append(dbus.String(segtypes))
 		else:
-			self._segs.extend(set(segtypes))
+			self._segs.extend([dbus.String(x) for x in set(segtypes)])
 
 		self.Vg = cfg.om.get_object_path_by_uuid_lvm_id(
 			vg_uuid, vg_name, vg_obj_path_generate)


