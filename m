From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:57 -0400
Subject: master - tests: improve mirror_images_redundant
Message-ID: <201804201102.w3KB2vkv031431@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d51429254f4e9b17083af0c554aa7045e5ec08bb
Commit:        d51429254f4e9b17083af0c554aa7045e5ec08bb
Parent:        ac18005de93de30db445e5fde6abdb801ee6e2a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 20 10:15:14 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

tests: improve mirror_images_redundant

Use only passed VG for lvs and avoid 1 extra uneeded use of lvs.
---
 test/lib/check.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index ed4f8d7..c796104 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -41,7 +41,6 @@ lvdevices() {
 mirror_images_redundant() {
 	local vg=$1
 	local lv="$vg/$2"
-	lvs -a "$vg" -o+devices
 	for i in $(lvdevices "$lv"); do
 		echo "# $i:"
 		lvdevices "$vg/$i" | sort | uniq
@@ -158,7 +157,7 @@ mirror_nonredundant() {
 	attr=$(get lv_field "$lv" attr)
 	(echo "$attr" | grep "^......m...$" >/dev/null) || {
 		if (echo "$attr" | grep "^o.........$" >/dev/null) &&
-		   lvs -a | grep -F "[${2}_mimage" >/dev/null; then
+		   lvs -a $1 | grep -F "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
 		else


