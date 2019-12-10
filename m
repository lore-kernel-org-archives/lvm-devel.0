From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:49 -0500
Subject: master - test: aux setup
Message-ID: <75024.119121009464000387@us-mta-270.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ab1d489f3e3ab140f014d5b5a10859e396bce66
Commit:        8ab1d489f3e3ab140f014d5b5a10859e396bce66
Parent:        89d839e54116d29e78909c63eb20ab50dc00e93f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 13:30:11 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

test: aux setup

Avoid endless loop if there was no 'remove' progress.
---
 test/lib/aux.sh |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 566e9b5..cbe0e21 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -382,7 +382,7 @@ teardown_devs_prefixed() {
 
 		while :; do
 			local sortby="name"
-			local num_devs=0
+			local progress=0
 
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			test "$i" = 0 || sortby="-minor"
@@ -392,23 +392,23 @@ teardown_devs_prefixed() {
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



