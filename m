From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:40 +0000 (UTC)
Subject: master - tests: add check lv_not_exists
Message-ID: <20140211180140.CACA860FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=177db48c11d1ac0794d805384b68de70703465b0
Commit:        177db48c11d1ac0794d805384b68de70703465b0
Parent:        4ed831e7ef4cc82c84731294f0189620ff5439c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 31 13:31:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 19:00:06 2014 +0100

tests: add check lv_not_exists

---
 test/lib/check.sh |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 84604e3..9c55338 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -240,7 +240,7 @@ inactive() {
 		die "$lv expected inactive, but lvs says it's not:" \
 			$(lvl $lv -o+devices)
 	not dmsetup info $1-$2 2>/dev/null || \
-		die "$lv expected inactive, lvs thinks it is but there are mappings!" 
+		die "$lv expected inactive, lvs thinks it is but there are mappings!"
 }
 
 # Check for list of LVs from given VG
@@ -251,10 +251,25 @@ lv_exists() {
 		shift
 		lv="$lv $vg/$1"
 	done
+	test -n "$lv" || lv=$vg
 	lvl $lv &>/dev/null || \
 		die "$lv expected to exist but does not"
 }
 
+lv_not_exists() {
+	local vg=$1
+	if test $# -le 1 ; then
+		lvl $vg &>/dev/null || return
+		die "$vg expected to not exist but it does!"
+	else
+		while [ $# -gt 1 ]; do
+			shift
+			lvl $vg/$1 &>/dev/null || continue
+			die "$vg/$1 expected to not exist but it does!"
+		done
+	fi
+}
+
 pv_field() {
 	local actual=$(get pv_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \


