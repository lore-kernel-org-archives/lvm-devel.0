From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Mar 2014 11:55:53 +0000 (UTC)
Subject: master - test: Make teardown (more) resistant to funny DM device names.
Message-ID: <20140304115553.A116B603AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb77bdc253e695c7e98b0095cb49a6e4f262e384
Commit:        cb77bdc253e695c7e98b0095cb49a6e4f262e384
Parent:        d739e16d85d95611a9f6edbde316c6627307d2ce
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Mon Mar 3 23:01:40 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Tue Mar 4 11:16:00 2014 +0100

test: Make teardown (more) resistant to funny DM device names.

---
 test/lib/aux.sh   |    4 ++--
 test/lib/utils.sh |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2d0f805..c178ab5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -141,7 +141,7 @@ teardown_devs_prefixed() {
 	local need_udev_wait=0
 	init_udev_transaction
 	for dm in $(dm_info name --sort open | grep "$prefix"); do
-		dmsetup remove "$dm" &>/dev/null || remfail=yes
+		dmsetup remove --mangle none "$dm" &>/dev/null || remfail=yes
 		need_udev_wait=1
 	done
 	finish_udev_transaction
@@ -154,7 +154,7 @@ teardown_devs_prefixed() {
 		    test $num_devs -lt $num_remaining_devs -a $num_devs -ne 0; do
 			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
 			for dm in $(dm_info name --sort open | grep "$prefix") ; do
-				dmsetup remove -f "$dm" || true
+				dmsetup remove --mangle none -f "$dm" || true
 			done
 			num_remaining_devs=$num_devs
 		done
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 0f58b25..819a0eb 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -159,7 +159,7 @@ teardown_udev_cookies() {
 }
 
 dm_info() {
-	should dmsetup info --noheadings -c -o "$@"
+	should dmsetup info --mangle none --noheadings -c -o "$@"
 }
 
 dm_table() {


