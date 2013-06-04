From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Jun 2013 13:58:44 +0000 (UTC)
Subject: master - tests: check for real mirror target type
Message-ID: <20130604135844.D0E1261120@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=215ab4c9cec497465a60b91ef53046665ed5e1d2
Commit:        215ab4c9cec497465a60b91ef53046665ed5e1d2
Parent:        fce72434270cb1bdd14ff896cd1640bc51c93084
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 4 11:08:45 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 4 15:57:42 2013 +0200

tests: check for real mirror target type

Use new available attr instead of guessing...
---
 test/lib/check.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index 48e3073..157434b 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -118,7 +118,7 @@ mirror() {
 mirror_nonredundant() {
 	local lv=$1/$2
 	local attr=$(get lv_field $lv attr)
-	(echo "$attr" | grep "^m........$" >/dev/null) || {
+	(echo "$attr" | grep "^......m..$" >/dev/null) || {
 		if (echo "$attr" | grep "^o........$" >/dev/null) &&
 		   lvs -a | fgrep "[${2}_mimage" >/dev/null; then
 			echo "TEST WARNING: $lv is a snapshot origin and looks like a mirror,"


