From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 25 Apr 2014 19:53:51 +0000 (UTC)
Subject: master - vgsplit: Make vgsplit work on mirrors with leg and log on same PV
Message-ID: <20140425195351.8B3AA61046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9ac858fe6b56318cee821e86e4a5edede75d5134
Commit:        9ac858fe6b56318cee821e86e4a5edede75d5134
Parent:        0ee9d59b48b7b5eb844f6857977641e7a95f7ccb
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Apr 25 14:53:34 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Apr 25 14:53:34 2014 -0500

vgsplit: Make vgsplit work on mirrors with leg and log on same PV

Given a named mirror LV, vgsplit will look for the PVs that compose it
and move them to a new VG.  It does this by first looking at the log
and then the legs.  If the log is on the same device as one of the mirror
images, a problem occurs.  This is because the PV is moved to the new VG
as the log is processed and thus cannot be found in the current VG when
the image is processed.  The solution is to check and see if the PV we are
looking for has already been moved to the new VG.  If so, it is not an
error.
---
 lib/metadata/metadata.c         |   23 +++++++++++++---
 test/shell/vgsplit-operation.sh |   55 +++++++++++++++++++++++++++++++++++++-
 2 files changed, 72 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6bc7e3a..edc55ef 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -360,14 +360,23 @@ out:
 	return r;
 }
 
-int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
-	    const char *pv_name)
+int _move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
+	     const char *pv_name, int enforce_pv_from_source)
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 
 	/* FIXME: handle tags */
 	if (!(pvl = find_pv_in_vg(vg_from, pv_name))) {
+		if (!enforce_pv_from_source &&
+		    (pvl = find_pv_in_vg(vg_to, pv_name)))
+			/*
+			 * PV has already been moved.  This can happen if an
+			 * LV is being moved that has multiple sub-LVs on the
+			 * same PV.
+			 */
+			return 1;
+
 		log_error("Physical volume %s not in volume group %s",
 			  pv_name, vg_from->name);
 		return 0;
@@ -391,6 +400,12 @@ int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	return 1;
 }
 
+int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
+	    const char *pv_name)
+{
+	return _move_pv(vg_from, vg_to, pv_name, 1);
+}
+
 int move_pvs_used_by_lv(struct volume_group *vg_from,
 			struct volume_group *vg_to,
 			const char *lv_name)
@@ -418,8 +433,8 @@ int move_pvs_used_by_lv(struct volume_group *vg_from,
 				return_0;
 		for (s = 0; s < lvseg->area_count; s++) {
 			if (seg_type(lvseg, s) == AREA_PV) {
-				if (!move_pv(vg_from, vg_to,
-					      pv_dev_name(seg_pv(lvseg, s))))
+				if (!_move_pv(vg_from, vg_to,
+					      pv_dev_name(seg_pv(lvseg, s)), 0))
 					return_0;
 			} else if (seg_type(lvseg, s) == AREA_LV) {
 				lv = seg_lv(lvseg, s);
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 4c9e6f1..097f0f5 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -79,6 +79,10 @@ COMM "vgsplit correctly splits mirror LV into $i VG ($j args)"
 
 		lvcreate -an -Zn -l 64 --type mirror -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
 		if [ $j = PV ]; then
+		  # FIXME: Not an exhaustive check of possible bad combinations
+		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
+		  not vgsplit $vg1 $vg2 "$dev1" "$dev3"
+		  not vgsplit $vg1 $vg2 "$dev2" "$dev3"
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
@@ -90,7 +94,27 @@ COMM "vgsplit correctly splits mirror LV into $i VG ($j args)"
 		fi
 		lvremove -f $vg2/$lv1
 		vgremove -f $vg2
-# FIXME: ensure split /doesn't/ work when not all devs of mirror specified
+
+# RHBZ 875903
+COMM "vgsplit correctly splits mirror (log+leg on same dev) into $i VG ($j args)"
+		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
+		test $i = existing && create_vg_ $vg2 "$dev4"
+
+		lvcreate -an -Zn -l 64 --type mirror -m1 -n $lv1 $vg1 "$dev1" "$dev2"
+		if [ $j = PV ]; then
+		  not vgsplit $vg1 $vg2 "$dev1"
+		  not vgsplit $vg1 $vg2 "$dev2"
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2"
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 3 1 0
+		else
+		  check pvlv_counts $vg2 2 1 0
+		fi
+		lvremove -f $vg2/$lv1
+		vgremove -f $vg1 $vg2
 
 COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
 		create_vg_ -c n $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
@@ -100,6 +124,11 @@ COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
 		    "$dev1" "$dev2" "$dev3" "$dev4"
 
 		if [ $j = PV ]; then
+		  # FIXME: Not an exhaustive check of possible bad combinations
+		  not vgsplit $vg1 $vg2 "$dev1" "$dev2"
+		  not vgsplit $vg1 $vg2 "$dev3" "$dev4"
+		  not vgsplit $vg1 $vg2 "$dev1" "$dev3"
+		  not vgsplit $vg1 $vg2 "$dev2" "$dev4"
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3" "$dev4"
 		else
 		  vgsplit -n $lv1 $vg1 $vg2
@@ -111,7 +140,29 @@ COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
 		fi
 		lvremove -f $vg2/$lv1
 		vgremove -f $vg2
-# FIXME: ensure split /doesn't/ work when not all devs of mirror specified
+
+# RHBZ 875903
+COMM "vgsplit correctly splits mirror LV with mirrored log on same devs into $i VG ($j args)"
+		create_vg_ -c n $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
+		test $i = existing && create_vg_ -c n $vg2 "$dev5"
+
+		lvcreate -an -Zn -l 64 --mirrorlog mirrored --type mirror -m1 -n $lv1 $vg1 \
+		    "$dev1" "$dev2"
+
+		if [ $j = PV ]; then
+		  not vgsplit $vg1 $vg2 "$dev1"
+		  not vgsplit $vg1 $vg2 "$dev2"
+		  vgsplit $vg1 $vg2 "$dev1" "$dev2"
+		else
+		  vgsplit -n $lv1 $vg1 $vg2
+		fi
+		if [ $i = existing ]; then
+		  check pvlv_counts $vg2 3 1 0
+		else
+		  check pvlv_counts $vg2 2 1 0
+		fi
+		lvremove -f $vg2/$lv1
+		vgremove -f $vg1 $vg2
 
 COMM "vgsplit correctly splits origin and snapshot LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2"


