From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Oct 2020 23:43:24 +0000 (GMT)
Subject: master - fsadm: handle fsck return 1 for corrected fs
Message-ID: <20201023234324.13706384A881@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=51a532719c80a91bf32339741d8df30ef593a8d4
Commit:        51a532719c80a91bf32339741d8df30ef593a8d4
Parent:        73ef86ae3fd51c921c3437a8c3da474e2861d217
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 24 00:42:31 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 24 01:42:16 2020 +0200

fsadm: handle fsck return 1 for corrected fs

---
 scripts/fsadm.sh | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index b84412d92..5ca80b4dd 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2007-2017 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2020 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -130,7 +130,15 @@ dry() {
 		return 0
 	fi
 	verbose "Executing" "$@"
-	"$@"
+	$@
+}
+
+# Accept as succss also return code 1 with fsck
+accept_0_1() {
+	$@
+	local ret="$?"
+	test "$ret" -eq 1 || return "$ret"
+	# Filesystem was corrected
 }
 
 cleanup() {
@@ -455,9 +463,10 @@ resize_ext() {
 		if test -n "$MOUNTED" ; then
 			# Forced fsck -f for umounted extX filesystem.
 			case "$-" in
-			  *i*) dry "$FSCK" $YES -f "$VOLUME" ;;
-			  *) dry "$FSCK" -f -p "$VOLUME" ;;
+			*i*) FLAG=$YES ;;
+			*)   FLAG="-p" ;;
 			esac
+			accept_0_1 dry "$FSCK" -f $FLAG "$VOLUME" || error "Failed to fsck $VOLUME"
 		fi
 	fi
 
@@ -742,9 +751,11 @@ check() {
 	  "ext2"|"ext3"|"ext4"|"reiserfs")
 	        # check if executed from interactive shell environment
 		case "$-" in
-		  *i*) dry "$FSCK" $YES $FORCE "$VOLUME" ;;
-		  *) dry "$FSCK" $FORCE -p "$VOLUME" ;;
-		esac ;;
+		  *i*) FLAG=$YES ;;
+		  *)   FLAG="-p" ;;
+		esac
+		accept_0_1 dry "$FSCK" $FORCE $FLAG "$VOLUME" || error "Fsck $FSTYPE failed."
+		;;
 	  "crypto_LUKS")
 		which "$CRYPTSETUP" >"$NULL" 2>&1 || error "$CRYPTSETUP utility required."
 		check_luks ;;


