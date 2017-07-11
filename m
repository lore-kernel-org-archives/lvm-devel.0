From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 19:22:51 -0400
Subject: master - tests: more exact test
Message-ID: <201707112322.v6BNMpn8010839@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1ed9bc1452129ca0553d76d890049d5873dd91f
Commit:        a1ed9bc1452129ca0553d76d890049d5873dd91f
Parent:        8387f4efc96d4a32446006dcc7f3d1aa039c8bfe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 01:16:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 01:21:44 2017 +0200

tests: more exact test

Check there is really just linear.

Also short-circuit mimages_are_on_ when file is empty
(avoids unbound  mimages[@] access on older bash)
---
 test/shell/mirror-vgreduce-removemissing.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 4068f09..c8f6411 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -50,6 +50,8 @@ mimages_are_on_ ()
 	printf "%s\n" "${list_pvs[@]}" | sort | uniq > out1
 
 	get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" | tee lvs_log
+	test -s lvs_log || return 1
+
 	while IFS= read -r i ; do
 		mimages+=( "$i" )
 	done < lvs_log
@@ -330,7 +332,6 @@ test_2way_mirror_plus_2_fail_3_()
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	mirrorlog_is_on_ $lv1 "$dev5"
 
-
 	list_pvs=(); while IFS= read -r line ; do
 		list_pvs+=( "$line" )
 	done < <( rest_pvs_ "$index" 4 )
@@ -339,7 +340,8 @@ test_2way_mirror_plus_2_fail_3_()
 	vgreduce --removemissing --force $vg
 	lvs -a -o+devices $vg
 	eval dev=\$dev$n
-	mimages_are_on_ $lv1 "$dev" || lv_is_on_ $lv1 "$dev"
+	not mimages_are_on_ $lv1 "$dev"
+	lv_is_on_ $lv1 "$dev"
 	not mirrorlog_is_on_ $lv1 "$dev5"
 }
 


