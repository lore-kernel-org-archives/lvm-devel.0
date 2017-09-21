From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 21 Sep 2017 11:17:26 -0400
Subject: master - blkdeactivate: fix blkdeactivate regression with failing DM/MD devs deactivation
Message-ID: <201709211517.v8LFHQiN021435@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7fa0d5226297a9ef57b8bce986e7a17ce948beb3
Commit:        7fa0d5226297a9ef57b8bce986e7a17ce948beb3
Parent:        9f34125d5d6f0755af8b99ec9ca04495cf8d8df6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Sep 21 13:39:52 2017 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Sep 21 17:10:15 2017 +0200

blkdeactivate: fix blkdeactivate regression with failing DM/MD devs deactivation

Revert dc50f2f4a03dd50c5e2411a258095484555421e9.

We're canonicalizing/escaping the names here and we're reusing the
variable name so the code doesn't need to use extra variables and
further assignments that may confuse us. Let's keep the code simple.

The

   local name=(...$name)

is not the same as

   local name
   name=(...$name)

(I know various code-checking tools fuss about this and recommend
the 2nd way, but let's ignore those tools' nitpicking here please.)
---
 WHATS_NEW_DM                |    1 +
 scripts/blkdeactivate.sh.in |    8 ++------
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2060ada..576e308 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.144 - 
 ======================================
+  Fix blkdeactivate regression with failing DM/MD devs deactivation (1.02.142).
   Fix typo in blkdeactivate's '--{dm,lvm,mpath}options' option name.
   Correct return value testing when get reserved values for reporting.
   Take -S with dmsetup suspend/resume/clear/wipe_table/remove/deps/status/table.
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 61c7a86..a7606b5 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -205,9 +205,7 @@ deactivate_holders () {
 }
 
 deactivate_dm () {
-	local name
-
-	name=$(printf "%s" "$name")
+	local name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/mapper/$name" || return 0
 	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
@@ -276,9 +274,7 @@ deactivate_lvm () {
 }
 
 deactivate_md () {
-	local name
-
-	name=$(printf "%s" "$name")
+	local name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/$name" || return 0
 	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 


