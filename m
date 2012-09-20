From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 20 Sep 2012 05:31:37 +0000 (UTC)
Subject: master - Fix tests to accept extended attribute
Message-ID: <20120920053137.D17872380@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d0dc63c8bcf255eb48a236824b6e8a58026f305
Commit:        9d0dc63c8bcf255eb48a236824b6e8a58026f305
Parent:        2e04681248b7c72ce295f538d698ae644c73cc9c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Sep 20 07:30:24 2012 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Sep 20 07:30:24 2012 +0200

Fix tests to accept extended attribute

attr field had a character (p)artial appended.
---
 test/lib/check.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 95bba4b..6b7849f 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -118,8 +118,8 @@ mirror() {
 mirror_nonredundant() {
 	local lv=$1/$2
 	local attr=$(get lv_field $lv attr)
-	(echo "$attr" | grep "^m.......$" >/dev/null) || {
-		if (echo "$attr" | grep "^o.......$" >/dev/null) &&
+	(echo "$attr" | grep "^m........$" >/dev/null) || {
+		if (echo "$attr" | grep "^o........$" >/dev/null) &&
 		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"
 			echo "assuming it is actually a mirror"
@@ -198,7 +198,7 @@ in_sync() {
 
 active() {
 	local lv=$1/$2
-	(get lv_field $lv attr | grep "^....a...$" >/dev/null) || \
+	(get lv_field $lv attr | grep "^....a....$" >/dev/null) || \
 		die "$lv expected active, but lvs says it's not:" \
 			$(lvl $lv -o+devices)
 	dmsetup info $1-$2 >/dev/null ||
@@ -207,7 +207,7 @@ active() {
 
 inactive() {
 	local lv=$1/$2
-	(get lv_field $lv attr | grep "^....[-isd]...$" >/dev/null) || \
+	(get lv_field $lv attr | grep "^....[-isd]....$" >/dev/null) || \
 		die "$lv expected inactive, but lvs says it's not:" \
 			$(lvl $lv -o+devices)
 	not dmsetup info $1-$2 2>/dev/null || \


