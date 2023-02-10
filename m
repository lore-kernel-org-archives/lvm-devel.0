From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:30 +0000 (GMT)
Subject: main - tests: fix cutandpaste bug in wrapper
Message-ID: <20230210165330.A060F385840D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b29b8e0bb293762dafd98bfbca0e225b23f0343b
Commit:        b29b8e0bb293762dafd98bfbca0e225b23f0343b
Parent:        a0437225aa799ed4685e60534fcbdc867fd26947
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 13:42:11 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

tests: fix cutandpaste bug in wrapper

Use correct variable name for assign.
---
 test/lib/lvm_vdo_wrapper.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/lvm_vdo_wrapper.sh b/test/lib/lvm_vdo_wrapper.sh
index 25a6ce0fe..d90ba8d42 100755
--- a/test/lib/lvm_vdo_wrapper.sh
+++ b/test/lib/lvm_vdo_wrapper.sh
@@ -113,7 +113,7 @@ do
 	  "--vdoLogicalSize") shift; vdo_logicalSize=$1 ;;
 	  "--vdoLogicalThreads") shift; vdo_logicalThreads=$1 ;;
 	  "--vdoLogLevel") shift ;;	# ignored
-	  "--vdoPhysicalThreads") shift; vdo_physicalSize=$1 ;;
+	  "--vdoPhysicalThreads") shift; vdo_physicalThreads=$1 ;;
 	  "--vdoSlabSize") shift; vdo_slabSize=$1 ;;
 	  "--verbose"|"-d"|"--debug") vdo_verbose="-v" ;;
 	  "--writePolicy") shift; vdo_writePolicy=$1 ;;

