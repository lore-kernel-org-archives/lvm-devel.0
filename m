From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 17 Sep 2021 14:50:49 +0000 (GMT)
Subject: main - lvm_import_vdo: --dry-run automatically verbose
Message-ID: <20210917145049.1D5CB3858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3817392d87f24c2d350f801daac2ee16358c1ecf
Commit:        3817392d87f24c2d350f801daac2ee16358c1ecf
Parent:        944e560e960964217c7525a18c60bf17ca046e0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 17 16:49:17 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 17 16:49:17 2021 +0200

lvm_import_vdo: --dry-run automatically verbose

Dry-run is way more usable when it's verbose.
---
 man/lvm_import_vdo.8_main | 2 +-
 scripts/lvm_import_vdo.sh | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvm_import_vdo.8_main b/man/lvm_import_vdo.8_main
index c812c5e01..23755a3aa 100644
--- a/man/lvm_import_vdo.8_main
+++ b/man/lvm_import_vdo.8_main
@@ -59,7 +59,7 @@ Answer "yes" at any prompts.
 .
 .TP
 .BR --dry-run
-Print commands without running them.
+Print verbosely commands without running them.
 .
 .
 .SH DIAGNOSTICS
diff --git a/scripts/lvm_import_vdo.sh b/scripts/lvm_import_vdo.sh
index 06cdb106d..7dc326d9f 100755
--- a/scripts/lvm_import_vdo.sh
+++ b/scripts/lvm_import_vdo.sh
@@ -73,7 +73,7 @@ tool_usage() {
 	echo "	  -n | --name	      Specifies VG/LV name for converted VDO volume"
 	echo "	  -v | --verbose      Be verbose"
 	echo "	  -y | --yes	      Answer \"yes\" at any prompts"
-	echo "	       --dry-run      Print commands without running them"
+	echo "	       --dry-run      Print verbosely commands without running them"
 
 	exit
 }
@@ -434,7 +434,7 @@ do
 	  "-n"|"--name"   ) shift; NAME=$1 ;;
 	  "-v"|"--verbose") VERB="-v" ;;
 	  "-y"|"--yes"    ) YES="-y" ;;
-	  "--dry-run"     ) DRY="1" ;;
+	  "--dry-run"     ) DRY="1" ; VERB="-v" ;;
 	  "-*") error "Wrong argument \"$1\". (see: $TOOL --help)" ;;
 	  *) DEVICENAME=$1 ;;  # device name does not start with '-'
 	esac


