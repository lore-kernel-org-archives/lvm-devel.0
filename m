From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:32:57 -0400
Subject: master - tests: aux.sh check for already present config
Message-ID: <201707101232.v6ACWvOW022721@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d426d7e7099b23d169e396292a25ab97cbfc2000
Commit:        d426d7e7099b23d169e396292a25ab97cbfc2000
Parent:        32c0dc35493c36b1f4d79264af1ad09a6150b198
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 23:03:08 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: aux.sh check for already present config

'aux lvmconf' detects if new config needs to be regenerated.
---
 test/lib/aux.sh |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 3f54dbb..13be7c5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1226,6 +1226,18 @@ EOF
 
 lvmconf() {
 	unset profile_name
+	test $# -eq 0 || {
+		# Compare if passed args aren't already all in generated lvm.conf
+		local needed=0
+		for i in "$@"; do
+			val=$(grep "${i%%[={ ]*}" CONFIG_VALUES 2>/dev/null | tail -1) || { needed=1; break; }
+			test "$val" = "$i" || { needed=1; break; }
+		done
+		test "$needed" -eq 0 && {
+			echo "## LVMCONF: values are already there, skipping."
+			return 0 # not needed
+		}
+	}
 	generate_config "$@"
 	mv -f CONFIG "$LVM_SYSTEM_DIR/lvm.conf"
 }


