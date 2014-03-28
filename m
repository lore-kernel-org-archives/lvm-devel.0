From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 28 Mar 2014 16:08:20 +0000 (UTC)
Subject: master - tests: more coverage for pvchange
Message-ID: <20140328160820.37C8E60AA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3181dc72e7fbca5a63a3fd077fce3eafa0808ac9
Commit:        3181dc72e7fbca5a63a3fd077fce3eafa0808ac9
Parent:        2a79971004d4fb14b4483d7a87eca6eae4b8dd72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 11:38:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 11:38:50 2014 +0100

tests: more coverage for pvchange

Change metadataignore
Argless pvchange
Alocatability for orphans
---
 test/shell/pvchange-usage.sh |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index a6a03fa..00489bd 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -13,14 +13,20 @@
 
 . lib/test
 
-aux prepare_devs 4
+check_changed_uuid_() {
+	test "$1" != "$(get pv_field "$2" uuid)" || die "UUID has not changed!"
+}
+
+aux prepare_pvs 4
 
 for mda in 0 1 2
 do
 # "setup pv with metadatacopies = $mda"
-	pvcreate "$dev4"
 	pvcreate --metadatacopies $mda "$dev1"
-	vgcreate $vg1 "$dev1" "$dev4"
+# cannot change allocatability for orphan PVs
+	fail pvchange "$dev1" -x y
+	fail pvchange "$dev1" -x n
+	vgcreate $vg1 "$dev4" "$dev1"
 
 # "pvchange adds/dels tag to pvs with metadatacopies = $mda "
 	pvchange "$dev1" --addtag test$mda
@@ -36,9 +42,16 @@ do
 	pvchange "$dev1" -x y   # already enabled
 	check pv_field "$dev1" pv_attr  a--
 
+# check we are able to change number of managed metadata areas
+	if test $mda -gt 0 ; then
+		pvchange --force --metadataignore y "$dev1"
+	else
+		# already ignored
+		fail pvchange --metadataignore y "$dev1"
+	fi
 # 'remove pv'
 	vgremove $vg1
-	pvremove "$dev1" "$dev4"
+	pvremove "$dev1"
 done
 
 # "pvchange uuid"
@@ -49,19 +62,22 @@ vgcreate $vg1 "$dev1" "$dev2"
 # Checking for different UUID after pvchange
 UUID1=$(get pv_field "$dev1" uuid)
 pvchange -u "$dev1"
-test "$UUID1" != "$(get pv_field "$dev1" uuid)" || die "UUID has not changed!"
+check_changed_uuid_ "$UUID1" "$dev1"
 
 UUID2=$(get pv_field "$dev2" uuid)
 pvchange -u "$dev2"
-test "$UUID2" != "$(get pv_field "$dev2" uuid)" || die "UUID has not changed!"
+check_changed_uuid_ "$UUID2" "$dev2"
 
 UUID1=$(get pv_field "$dev1" uuid)
 UUID2=$(get pv_field "$dev2" uuid)
 pvchange -u --all
-test "$UUID1" != "$(get pv_field "$dev1" uuid)" || die "UUID has not changed!"
-test "$UUID2" != "$(get pv_field "$dev2" uuid)" || die "UUID has not changed!"
+check_changed_uuid_ "$UUID1" "$dev1"
+check_changed_uuid_ "$UUID2" "$dev2"
 check pvlv_counts $vg1 2 0 0
 
+# some args are needed
+invalid pvchange
+
 # '-a' needs more params
 invalid pvchange -a
 # '-a' is searching for devs, so specifying device is invalid


