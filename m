From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 May 2014 10:02:27 +0000 (UTC)
Subject: master - tests: add check vg_attr_bit
Message-ID: <20140522100227.6C52C611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1208e92b3476d4350b0734897ed9adb30697dcfd
Commit:        1208e92b3476d4350b0734897ed9adb30697dcfd
Parent:        406ce3760bb619a3104ca2ef58e809c29907d506
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 22 11:59:11 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 22 12:01:44 2014 +0200

tests: add check vg_attr_bit

Similar function like  'check lv_attr_bit'
---
 test/lib/check.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 9c80d9a..cd29ef4 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -282,6 +282,21 @@ vg_field() {
 		die "vg_field: vg=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
+vg_attr_bit() {
+	local actual=$(get vg_field "$2" vg_attr "${@:4}")
+	local offset=$1
+	case "$offset" in
+	  perm*) offset=0 ;;
+	  resiz*) offset=1 ;;
+	  export*) offset=2 ;;
+	  partial) offset=3 ;;
+	  alloc*) offset=4 ;;
+	  cluster*) offset=5 ;;
+	esac
+	test "${actual:$offset:1}" = "$3" || \
+		die "vg_attr_bit: vg=$2, ${offset} bit of \"$actual\" is \"${actual:$offset:1}\", but expected \"$3\""
+}
+
 lv_field() {
 	local actual=$(get lv_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \


