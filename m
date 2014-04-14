From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:28 +0000 (UTC)
Subject: master - tests: implement lv_attr_bit
Message-ID: <20140414110628.B8CD760CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d48577ab9fce971512a5c7b2faf3bfdf683f512
Commit:        4d48577ab9fce971512a5c7b2faf3bfdf683f512
Parent:        1d803ee9806bc3838a515619bec211b9233d803e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 10 22:07:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:02:28 2014 +0200

tests: implement lv_attr_bit

Add easy check function for cheking lv_attr bits
---
 test/lib/check.sh |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 20ad6c3..9c80d9a 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -285,7 +285,26 @@ vg_field() {
 lv_field() {
 	local actual=$(get lv_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
-		die "lv_field: lv=$lv, field=\"$2\", actual=\"$actual\", expected=\"$3\""
+		die "lv_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
+}
+
+lv_attr_bit() {
+	local actual=$(get lv_field "$2" lv_attr "${@:4}")
+	local offset=$1
+	case "$offset" in
+	  type) offset=0 ;;
+	  perm*) offset=1 ;;
+	  alloc*) offset=2 ;;
+	  fixed*) offset=3 ;;
+	  state) offset=4 ;;
+	  open) offset=5 ;;
+	  target) offset=6 ;;
+	  zero) offset=7 ;;
+	  health) offset=8 ;;
+	  skip) offset=9 ;;
+	esac
+	test "${actual:$offset:1}" = "$3" || \
+		die "lv_attr_bit: lv=$2, ${offset} bit of \"$actual\" is \"${actual:$offset:1}\", but expected \"$3\""
 }
 
 compare_fields() {


