From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 5 Oct 2017 04:26:01 -0400
Subject: master - fsadm: add --help
Message-ID: <201710050826.v958Q1iY026285@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ae8adce928d4ce6ef36c87c2a0bb8aa737346b8
Commit:        3ae8adce928d4ce6ef36c87c2a0bb8aa737346b8
Parent:        9940c2f754e3292b6d96628682c254941ae6cc58
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 5 10:16:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 5 10:23:20 2017 +0200

fsadm: add --help

Newer version of blockdev tool needs --help as the tool is no longer
printing help without this option like it used to in past.
---
 WHATS_NEW        |    1 +
 scripts/fsadm.sh |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b2037a6..0cdd398 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.175 - 
 ======================================
+  Use --help with blockdev when checking for --getsize64 support in fsadm.
   Fix metadata corruption in vgsplit intermediate state.
   Require LV name with pvmove in a shared VG.
   Allow shared active mirror LVs with lvmlockd, dlm, and cmirrord.
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 459905f..753da2b 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -365,7 +365,7 @@ detect_mounted() {
 # get the full size of device in bytes
 detect_device_size() {
 	# check if blockdev supports getsize64
-	"$BLOCKDEV" 2>&1 | "$GREP" getsize64 >"$NULL"
+	"$BLOCKDEV" --help 2>&1 | "$GREP" getsize64 >"$NULL"
 	if test $? -eq 0; then
 		DEVSIZE=$("$BLOCKDEV" --getsize64 "$VOLUME")
 		test -n "$DEVSIZE" || error "Cannot read size of device \"$VOLUME\"."


