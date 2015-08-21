From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 21 Aug 2015 20:27:12 +0000 (UTC)
Subject: master - tests: add lib function to test hidden LVs with lvs -a
Message-ID: <20150821202712.AC07560DAA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e53758c5f6074f920325afe0a01616f7c663f766
Commit:        e53758c5f6074f920325afe0a01616f7c663f766
Parent:        1f27c9f6a44cb893b6653641b35295e129531bf8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 21 15:06:00 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 21 15:09:38 2015 -0500

tests: add lib function to test hidden LVs with lvs -a

---
 test/lib/check.sh |    6 ++++++
 test/lib/get.sh   |    5 +++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index a6a9b38..9d48851 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -308,6 +308,12 @@ lv_field() {
 		die "lv_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
+lva_field() {
+	local actual=$(get lva_field "$1" "$2" "${@:4}")
+	test "$actual" = "$3" || \
+		die "lva_field: lv=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
+}
+
 lv_attr_bit() {
 	local actual=$(get lv_field "$2" lv_attr "${@:4}")
 	local offset=$1
diff --git a/test/lib/get.sh b/test/lib/get.sh
index ef1ddc4..1b432c6 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -42,6 +42,11 @@ lv_field() {
 	trim_ "$r"
 }
 
+lva_field() {
+	local r=$(lvs -a --config 'log{prefix=""}' --noheadings -o "$2" "${@:3}" "$1")
+	trim_ "$r"
+}
+
 lv_devices() {
 	lv_field "$1" devices -a "${@:2}" | sed 's/([^)]*)//g; s/,/\n/g'
 }


