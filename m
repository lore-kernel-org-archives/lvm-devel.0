From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:37:27 -0400
Subject: master - tests: check mirror_images_on fixed
Message-ID: <201707101237.v6ACbRHB023397@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fdbb680531b08e03dba2dc3d2f22381bf55abbb0
Commit:        fdbb680531b08e03dba2dc3d2f22381bf55abbb0
Parent:        91d6a62fc594152964ea25c44691c02ae23cdb9a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 21:17:03 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: check mirror_images_on fixed

Fix mirror_images_on() to actually report something useful (thought
it might be tuned later).

So for now the function got through all '_mimages_' and compares
where the order of them is matching given list of devices.
---
 test/lib/check.sh |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 603f334..76015b8 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -90,12 +90,18 @@ lv_tree_on() {
 	lv_on_diff_ devs[@] "$@"
 }
 
+# Test if all mimage_X LV legs are sitting on given ordered list of PVs
+# When LV is composed of imagetmp, such leg is decomposed so only
+# real _mimage LVs are always checked
 mirror_images_on() {
 	local vg=$1
 	local lv=$2
 	shift 2
-	for i in $(lvdevices "$lv"); do
-		lv_on "$vg" "$lv" "$1"
+	local mimages=()
+	readarray -t mimages <<< "$(get lv_field_lv_ "$vg" lv_name -a | grep "${lv}_mimage_" )"
+
+	for i in  "${mimages[@]}"; do
+		lv_on "$vg" "$i" "$1"
 		shift
 	done
 }


