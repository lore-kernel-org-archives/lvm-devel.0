From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Sep 2013 09:23:14 +0000 (UTC)
Subject: master - tests: update check and get
Message-ID: <20130916092314.3164A60E77@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9df27c42794652cc663e04c5c751daa549e73194
Commit:        9df27c42794652cc663e04c5c751daa549e73194
Parent:        51d3667cb559e77cd43556851922cb5bef0fc9ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 16 11:12:37 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 16 11:22:04 2013 +0200

tests: update check and get

Update usage of "" around shell vars.
trim needs to trim both sides now.
trim also removes debug.log since it's only called when lvm command
has finished properly (so if something fails afterward, there
is no missleading debug trace in the log)
---
 test/lib/check.sh |    4 ++--
 test/lib/get.sh   |   19 +++++++++++--------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/test/lib/check.sh b/test/lib/check.sh
index ecb0721..d3678a9 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -236,13 +236,13 @@ pv_field() {
 }
 
 vg_field() {
-	local actual=$(get vg_field $1 "$2" "${@:4}")
+	local actual=$(get vg_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "vg_field: vg=$1, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
 
 lv_field() {
-	local actual=$(get lv_field $1 "$2" "${@:4}")
+	local actual=$(get lv_field "$1" "$2" "${@:4}")
 	test "$actual" = "$3" || \
 		die "lv_field: lv=$lv, field=\"$2\", actual=\"$actual\", expected=\"$3\""
 }
diff --git a/test/lib/get.sh b/test/lib/get.sh
index 4197f47..7d7c3d2 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -18,28 +18,31 @@
 #
 #  get lv_devices LV     [lvs params]
 
+test -z "$BASH" || set -e -o pipefail
 
-# trims only leading prefix, we should not need trim trailing spaces
+# trims only leading prefix and suffix
 trim_() {
-	#local var=${var%"${var##*[! ]}"}  # remove trailing space characters
-	echo ${1#"${1%%[! ]*}"} # remove leading space characters
+	rm -f debug.log             # drop log, command was ok
+	local var=${1%${1##*[! ]}}  # remove trailing space characters
+	echo "${var#${var%%[! ]*}}" # remove leading space characters
 }
 
 pv_field() {
-	trim_ "$(pvs --noheadings -o $2 ${@:3} $1)"
+	trim_ "$(pvs --config 'log{prefix=""}' --noheadings -o $2 ${@:3} $1)"
 }
 
 vg_field() {
-	trim_ "$(vgs --noheadings -o $2 ${@:3} $1)"
+	trim_ "$(vgs --config 'log{prefix=""}' --noheadings -o $2 ${@:3} $1)"
 }
 
 lv_field() {
-	trim_ "$(lvs --noheadings -o $2 ${@:3} $1)"
+	trim_ "$(lvs --config 'log{prefix=""}' --noheadings -o $2 ${@:3} $1)"
 }
 
 lv_devices() {
-	lv_field $1 devices -a "${@:2}" | sed 's/([^)]*)//g; s/,/ /g'
+	lv_field "$1" devices -a "${@:2}" | sed 's/([^)]*)//g; s/,/\n/g'
 }
 
+#set -x
 unset LVM_VALGRIND
 "$@"


