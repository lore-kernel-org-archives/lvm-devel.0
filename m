From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:29 +0000 (UTC)
Subject: master - tests: workaround bash bug
Message-ID: <20140310112729.D1AFB60F97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6cc75d149710aa0ffbdfe58e4abc92572cbed07a
Commit:        6cc75d149710aa0ffbdfe58e4abc92572cbed07a
Parent:        4eed2c8142dc50e1d359881027aa38a4e4ef2149
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 23:07:50 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:10 2014 +0100

tests: workaround bash bug

Seems new bash4.3 is somewhat buggy
https://bugzilla.redhat.com/show_bug.cgi?id=1074202

Put in cheap workaround for now.
---
 test/lib/check.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 9c55338..20ad6c3 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -60,13 +60,13 @@ lv_err_list_() {
 }
 
 lv_on_diff_() {
-	declare -a devs=("${!1}") # pass in shell array
+	declare -a xdevs=("${!1}") # pass in shell array
 	local expect=( "${@:4}" ) # make an array starting from 4th args...
 	local diff_e
 
 	# Find diff between 2 shell arrays, print them as stdin files
 	printf "%s\n" "${expect[@]}" | sort | uniq >_lv_on_diff1
-	printf "%s\n" "${devs[@]}" >_lv_on_diff2
+	printf "%s\n" "${xdevs[@]}" >_lv_on_diff2
 	diff_e=$(diff _lv_on_diff1 _lv_on_diff2) ||
 		die "LV $2/$3 $(lv_err_list_ "^>" "${diff_e}" found)$(lv_err_list_ "^<" "${diff_e}" "not found")."
 }


