From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 May 2017 08:03:19 -0400
Subject: master - fsadm: avoid hidden --yes
Message-ID: <201705231203.v4NC3Ji6008985@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1fe4f80e45a6bfcceed5aaab97fc0e27dfcf2b88
Commit:        1fe4f80e45a6bfcceed5aaab97fc0e27dfcf2b88
Parent:        57492a609410c39809960a6f32bf67e1eddb7064
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 23 13:58:12 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 23 14:02:41 2017 +0200

fsadm: avoid hidden --yes

When 'fsadm' was running without terminal (i.e. pipe), it's been
automatically working like in '--yes'.

Detect terminal and only accept empty "" input in this mode.
---
 WHATS_NEW        |    1 +
 scripts/fsadm.sh |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 82397a9..f38c23c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Stop using '--yes' mode when fsadm runs without terminal.
   Extend validation of filesystems resized by fsadm.
   Enhance lvconvert automatic settings of possible (raid) LV types.
   Allow lvchange to change properties on a thin pool data sub LV.
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index bd54a26..ea14efe 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -401,10 +401,15 @@ yes_no() {
 
 	while read -r -s -n 1 ANS ; do
 		case "$ANS" in
-		 "y" | "Y" | "") echo y ; return 0 ;;
-		 "n" | "N") echo n ; return 1 ;;
+		 "y" | "Y" ) echo y ; return 0 ;;
+		 "" ) if [ -t 1 ] ; then
+			echo y ; return 0
+		      fi ;;
 		esac
 	done
+
+	echo n
+	return 1
 }
 
 try_umount() {


