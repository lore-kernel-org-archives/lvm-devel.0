From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Mar 2014 20:55:58 +0000 (UTC)
Subject: master - tests: disable test which leaks node
Message-ID: <20140302205558.C5A7E611B2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ff10f5e61df721ea06dc23575932df2d0215c50
Commit:        3ff10f5e61df721ea06dc23575932df2d0215c50
Parent:        75b5855ca1b4d524cb30a4373d1d2fe81d7b21f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 2 19:16:48 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 2 21:27:26 2014 +0100

tests: disable test which leaks node

This test is not detected as fault but leak device node
on a real /dev.
Added FIXME.
---
 test/shell/name-mangling.sh |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 4522a55..b5906c1 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -83,9 +83,9 @@ function check_create_and_remove()
 function check_dm_field()
 {
 	local mode=$1
-	local dm_name="$2"
+	local dm_name=$2
 	local field=$3
-	local expected="$4"
+	local expected=$4
 
 	value=$(dmsetup info --rows --noheadings --manglename $mode -c -o $field "${DM_DEV_DIR}/mapper/${PREFIX}$dm_name" 2> err || true)
 
@@ -103,7 +103,7 @@ function check_dm_field()
 function check_expected_names()
 {
 	local mode=$1
-	local dm_name="$2"
+	local dm_name=$2
 	local r=0
 
 	create_dm_dev none "$dm_name"
@@ -122,8 +122,8 @@ function check_expected_names()
 function check_mangle_cmd()
 {
 	local mode=$1
-	local dm_name="$2"
-	local expected="$3"
+	local dm_name=$2
+	local expected=$3
 	local rename_expected=0
 	local r=0
 
@@ -191,7 +191,11 @@ check_expected_names none 'a\x5cx20b' 'a\x5cx20b' 'a\x5cx20b' 'a\x20b'
 
 check_mangle_cmd none 'a b' 'OK'
 check_mangle_cmd none 'a\x20b' 'a b'
-check_mangle_cmd none 'a b\x20c' 'a b c'
+#
+# FIXME: this test leave entry in /dev/mapper dir
+#        and is not detected nor cleaned
+#
+#check_mangle_cmd none 'a b\x20c' 'a b c'
 check_mangle_cmd none 'a\x5cx20b' 'a\x20b'
 
 


