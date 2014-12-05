From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  5 Dec 2014 12:41:49 +0000 (UTC)
Subject: master - raid: properly rename split image
Message-ID: <20141205124149.B164360D56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3bd9a2797816e1d21003914c4bfa6c19eb3be62
Commit:        f3bd9a2797816e1d21003914c4bfa6c19eb3be62
Parent:        00d53d5fc172ee396ea835a110126f83202724d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 4 14:24:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 5 13:39:42 2014 +0100

raid: properly rename split image

When we split leg from raid - we take a proper new lock for a new LV.
However for now activation checks only 'existince' of device UUID,
but it's not validating device has a proper name.

As a quick fix call suspend()/resume() to rename after split mirror.
---
 WHATS_NEW                    |    1 +
 lib/metadata/raid_manip.c    |   16 ++++++++++++++++
 test/shell/lvconvert-raid.sh |    2 ++
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 11fa6e1..213cc31 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Correctly rename active split LV with -splitmirrors for raid1.
   Add report/compact_output to lvm.conf to enable/disable compact report output.
   Still restrict mirror region size to power of 2 when VG extent size is not.
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5eab551..59d3adb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1164,6 +1164,22 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 	if (!activate_lv_excl_local(cmd, lvl->lv))
 		return_0;
 
+	/*
+	 * Since newly split LV is typically already active - we need to call
+	 * suspend() and resume() to also rename it.
+	 *
+	 * TODO: activate should recognize it and avoid these 2 calls
+	 */
+	if (!suspend_lv(cmd, lvl->lv)) {
+		log_error("Failed to suspend %s.", lvl->lv->name);
+		return 0;
+	}
+
+	if (!resume_lv(cmd, lvl->lv)) {
+		log_error("Failed to reactivate %s.", lvl->lv->name);
+		return 0;
+	}
+
 	dm_list_iterate_items(lvl, &removal_list)
 		if (!activate_lv_excl_local(cmd, lvl->lv))
 			return_0;
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index bcf3874..8621311 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -107,6 +107,7 @@ aux wait_for_sync $vg $lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check lv_exists $vg $lv1
 check linear $vg $lv2
+check active $vg $lv2
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 
@@ -116,6 +117,7 @@ aux wait_for_sync $vg $lv1
 lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
 check linear $vg $lv1
 check linear $vg $lv2
+check active $vg $lv2
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 


