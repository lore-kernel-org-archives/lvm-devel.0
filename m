From: Ondrej Kozina <okozina@sourceware.org>
Date: Wed, 11 Oct 2017 08:40:14 -0400
Subject: master - fsadm: fail 'check' explicitly on unsupported fs type
Message-ID: <201710111240.v9BCeEYP020744@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c795a3b37f042d30bc706f73c67ff09c30addca6
Commit:        c795a3b37f042d30bc706f73c67ff09c30addca6
Parent:        74fd0dd6c49b1669a7e54b6c2fc9152c908fb2c6
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Wed Oct 11 10:20:38 2017 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Oct 11 14:39:15 2017 +0200

fsadm: fail 'check' explicitly on unsupported fs type

---
 scripts/fsadm.sh |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index e86d266..6210eb2 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -725,11 +725,14 @@ check() {
 			# Think about better way....
 			dry "$XFS_REPAIR" -n -o force_geometry "$VOLUME"
 		 fi ;;
-	  *)    # check if executed from interactive shell environment
+	  "ext2"|"ext3"|"ext4"|"reiserfs")
+	        # check if executed from interactive shell environment
 		case "$-" in
 		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
 		  *) dry "$FSCK" $FORCE -p "$VOLUME" ;;
-		esac
+		esac ;;
+	  *)
+		error "Filesystem \"$FSTYPE\" on device \"$VOLUME\" is not supported by this tool." ;;
 	esac
 }
 


