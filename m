From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  4 Dec 2013 18:53:13 +0000 (UTC)
Subject: master - tests: replace built-in popen
Message-ID: <20131204185313.7318A6066D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9461ae89bd725c24448ce84c7e5c7ea9cb7e29e
Commit:        d9461ae89bd725c24448ce84c7e5c7ea9cb7e29e
Parent:        e06cfd74373ae7928ef2a340b00e9bc3da8753ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 19:50:53 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Dec 4 19:50:53 2013 +0100

tests: replace built-in popen

It seems some older bashes have problems to properly execute
both pipes - so replace this code with separate temporary files.
---
 test/lib/check.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 4847de1..84604e3 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -65,7 +65,9 @@ lv_on_diff_() {
 	local diff_e
 
 	# Find diff between 2 shell arrays, print them as stdin files
-	diff_e=$(diff <(printf "%s\n" "${expect[@]}" | sort | uniq ) <(printf "%s\n" "${devs[@]}") ) ||
+	printf "%s\n" "${expect[@]}" | sort | uniq >_lv_on_diff1
+	printf "%s\n" "${devs[@]}" >_lv_on_diff2
+	diff_e=$(diff _lv_on_diff1 _lv_on_diff2) ||
 		die "LV $2/$3 $(lv_err_list_ "^>" "${diff_e}" found)$(lv_err_list_ "^<" "${diff_e}" "not found")."
 }
 


