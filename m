From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  6 Jun 2016 13:03:17 +0000 (UTC)
Subject: master - blkdeactivate: fix regression in blkdeactivate causing dm and md devices to be skipped.
Message-ID: <20160606130317.0B01260B26@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ae05adf462b8de4428f32600fb43583dce5009a
Commit:        7ae05adf462b8de4428f32600fb43583dce5009a
Parent:        7c894911aee47662e8f85f4458d65baea97eb058
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 6 14:57:41 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 6 14:57:46 2016 +0200

blkdeactivate: fix regression in blkdeactivate causing dm and md devices to be skipped.

Commit #5b3a4a9 caused the "name" variable to be cleared if
declaration and assignment is on two lines so put it back
so it's on one line for it to work again.
---
 WHATS_NEW                   |    1 +
 scripts/blkdeactivate.sh.in |    6 ++----
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c1b90af..2e7e138 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.156 - 
 ================================
+  Fix regression in blkdeactivate causing dm and md devices to be skipped. (2.02.155)
 
 Version 2.02.155 - 3rd June 2016
 ================================
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 2a48b3e..b4c3237 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -193,8 +193,7 @@ deactivate_holders () {
 }
 
 deactivate_dm () {
-	local name
-	name=$(printf "%s" "$name")
+	local name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/mapper/$name" || return 0
 	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
 
@@ -263,8 +262,7 @@ deactivate_lvm () {
 }
 
 deactivate_md () {
-	local name
-	name=$(printf "%s" "$name")
+	local name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/$name" || return 0
 	test -z ${SKIP_DEVICE_LIST["$kname"]} || return 1
 


