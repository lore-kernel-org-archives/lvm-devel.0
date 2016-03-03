From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:41 +0000 (UTC)
Subject: master - tests: add "get lvh_field" for "lvs -H"
Message-ID: <20160303132041.F15CA6033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45c82260db1c25f3885ea0e2185d7c3e7c33ed26
Commit:        45c82260db1c25f3885ea0e2185d7c3e7c33ed26
Parent:        b39473a537249b60e36f69e28155bfc6829763ab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:32:20 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

tests: add "get lvh_field" for "lvs -H"

---
 test/lib/check.sh |    6 ++++++
 test/lib/get.sh   |    5 +++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 4ede0be..e729ab2 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -310,6 +310,12 @@ lv_field() {
 		die "lv_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
+lvh_field() {
+	local actual=$(get lvh_field "$1" "$2" "${@:4}")
+	test "$actual" = "$3" || \
+		die "lvh_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
+}
+
 lva_field() {
 	local actual=$(get lva_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
diff --git a/test/lib/get.sh b/test/lib/get.sh
index 0d22eb4..74ee7e8 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -42,6 +42,11 @@ lv_field() {
 	trim_ "$r"
 }
 
+lvh_field() {
+	local r=$(lvs -H --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	trim_ "$r"
+}
+
 lva_field() {
 	local r=$(lvs -a --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
 	trim_ "$r"


