From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:19 +0000 (GMT)
Subject: stable-2.02 - tests: aux setup
Message-ID: <20201016191219.844DC396EC72@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b3d0166ee2057ddaac3e73955e07acb1204be42
Commit:        6b3d0166ee2057ddaac3e73955e07acb1204be42
Parent:        4d8d8856f12cab71663325eefe59c06f10cb884d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 13:30:11 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: aux setup

Avoid endless loop if there was no 'remove' progress.
---
 test/lib/aux.sh | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 667ca14ac..a84d41189 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -437,7 +437,7 @@ teardown_devs_prefixed() {
 
 		while :; do
 			local sortby="name"
-			local num_devs=0
+			local progress=0
 
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			test "$i" = 0 || sortby="-minor"
@@ -447,23 +447,23 @@ teardown_devs_prefixed() {
 				DM_NAME=${dm##DM_NAME=}
 				DM_NAME=${DM_NAME%%;DM_OPEN*}
 				DM_OPEN=${dm##*;DM_OPEN=}
+				local force="-f"
 				if test "$i" = 0; then
 					if test "$once" = 1 ; then
 						once=0
 						echo "## removing stray mapped devices with names beginning with $prefix: "
 					fi
 					test "$DM_OPEN" = 0 || break  # stop loop with 1st. opened device
-					dmsetup remove "$DM_NAME" --mangle none || true # &>/dev/null || touch REMOVE_FAILED &
-				else
-					dmsetup remove -f "$DM_NAME" --mangle none || true
+					force=""
 				fi
 
-				num_devs=$(( num_devs + 1 ))
+				# Succesfull 'remove' signals progress
+				dmsetup remove $force "$DM_NAME" --mangle none && progress=1
 			done
 
 			test "$i" = 0 || break
 
-			test "$num_devs" -gt 0 || break
+			test "$progress" = 1 || break
 
 			udev_wait
 			wait


