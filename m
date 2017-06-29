From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:45 -0400
Subject: master - blkdeactivate: split local declaration and assign
Message-ID: <201706292025.v5TKPjZn025706@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dc50f2f4a03dd50c5e2411a258095484555421e9
Commit:        dc50f2f4a03dd50c5e2411a258095484555421e9
Parent:        ce1383fe46d2b830a89acaa9fe00fb1239be4969
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 16:50:34 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

blkdeactivate: split local declaration and assign

---
 scripts/blkdeactivate.sh.in |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 69f02b0..b963a10 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -205,7 +205,9 @@ deactivate_holders () {
 }
 
 deactivate_dm () {
-	local name=$(printf "%s" "$name")
+	local name
+
+	name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/mapper/$name" || return 0
 	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
@@ -274,7 +276,9 @@ deactivate_lvm () {
 }
 
 deactivate_md () {
-	local name=$(printf "%s" "$name")
+	local name
+
+	name=$(printf "%s" "$name")
 	test -b "$DEV_DIR/$name" || return 0
 	test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 


