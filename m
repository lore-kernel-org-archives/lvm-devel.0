From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:00 +0000 (GMT)
Subject: dev-next - tests: update mirror test
Message-ID: <20210322153900.3BF2D385781A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92ee16f7c0d5d6983b90fe97d31e2884a8e5804d
Commit:        92ee16f7c0d5d6983b90fe97d31e2884a8e5804d
Parent:        53bad89a7b802890067e1c006775345098cfa4dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 21:18:53 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: update mirror test

Log results of uniq.
Remove few unneeded lvs calls.
---
 test/shell/mirror-vgreduce-removemissing.sh | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index f2f7c1973..ff7eea51f 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -44,7 +44,7 @@ mimages_are_on_ ()
 	local i
 
 	echo "Check if mirror images of $lv are on PVs" "${list_pvs[@]}"
-	printf "%s\n" "${list_pvs[@]}" | sort | uniq > out1
+	printf "%s\n" "${list_pvs[@]}" | sort | uniq | tee out1
 
 	get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" | tee lvs_log
 	test -s lvs_log || return 1
@@ -53,14 +53,9 @@ mimages_are_on_ ()
 		mimages+=( "$i" )
 	done < lvs_log
 
-	for i in "${mimages[@]}"; do
-		echo "Checking $vg/$i"
-		lvs -a -o+devices "$vg/$i"
-	done
-
 	for i in "${mimages[@]}"; do
 		get lv_devices "$vg/$i"
-	done | sort | uniq > out2
+	done | sort | uniq | tee out2
 
 	diff --ignore-blank-lines out1 out2
 }
@@ -116,7 +111,7 @@ prepare_lvs_()
 
 check_and_cleanup_lvs_()
 {
-	lvs -a -o+devices $vg
+	lvs -a -o+lv_uuid,devices $vg
 	prepare_lvs_
 }
 


