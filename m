From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  8 Dec 2020 21:17:46 +0000 (GMT)
Subject: stable-2.02 - fsadm: fix unbound variable usage
Message-ID: <20201208211746.8363B386100A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=307acb072b68956bf7c08dc88b6927f6abf3d2e4
Commit:        307acb072b68956bf7c08dc88b6927f6abf3d2e4
Parent:        da7ec2ec0f19dca9266ecb2a653485491cae850a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 7 16:16:55 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 8 22:17:17 2020 +0100

fsadm: fix unbound variable usage

When 'fsadm resize vg/lv' is used without size, it should just
resize filesystem to match device - but since we now check
for unbound variable in bash - the previous usage no longer
works and needs explicit check.
---
 scripts/fsadm.sh | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 9b95d318d..2cb1fc75b 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -798,6 +798,7 @@ fi
 
 CHECK=""
 RESIZE=""
+NEWSIZE=""
 
 while [ "$#" -ne 0 ]
 do
@@ -811,8 +812,11 @@ do
 	  "-y"|"--yes") YES="-y" ;;
 	  "-l"|"--lvresize") DO_LVRESIZE=1 ;;
 	  "-c"|"--cryptresize") DO_CRYPTRESIZE=1 ;;
-	  "check") CHECK=$2 ; shift ;;
-	  "resize") RESIZE=$2 ; NEWSIZE=$3 ; shift 2 ;;
+	  "check") test -z "${2-}" && error "Missing <device>. (see: $TOOL --help)"
+		   CHECK=$2 ; shift ;;
+	  "resize") test -z "${2-}" && error "Missing <device>. (see: $TOOL --help)"
+		    RESIZE=$2 ; shift
+		    if test -n "${2-}" ; then NEWSIZE="${2-}" ; shift ; fi ;;
 	  *) error "Wrong argument \"$1\". (see: $TOOL --help)"
 	esac
 	shift


