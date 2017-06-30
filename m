From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 06:13:53 -0400
Subject: master - tests: check.sh uses array for list
Message-ID: <201706301013.v5UADrhp020355@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e84a145cf4f593a4560f109b486a1fa1d999fe2d
Commit:        e84a145cf4f593a4560f109b486a1fa1d999fe2d
Parent:        c613fa48ffc0b4b89beedb93612270b29cc41fb9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 11:06:19 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 12:09:10 2017 +0200

tests: check.sh uses array for list

For properly quoted args, switch to use arrays for arg list.
---
 test/lib/check.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index a43aef7..c8efcca 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -261,14 +261,14 @@ inactive() {
 # Check for list of LVs from given VG
 lv_exists() {
 	local vg=$1
-	local lv=
+	declare -a list=()
 	while [ $# -gt 1 ]; do
 		shift
-		lv="$lv $vg/$1"
+		list+=( "$vg/$1" )
 	done
-	test -n "$lv" || lv=$vg
-	lvl "$lv" &>/dev/null || \
-		die "$lv expected to exist but does not"
+	test  "${#list[@]}" -gt 0 || list=( "$vg" )
+	lvl "${list[@]}" &>/dev/null || \
+		die "${list[@]}" "expected to exist, but does not!"
 }
 
 lv_not_exists() {


