From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Apr 2018 04:42:56 -0400
Subject: master - aux: enhance teardown to better handle weird names
Message-ID: <201804300842.w3U8guQw017302@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd7ac793a02553c9c7a14b9715d5a6ad636aa065
Commit:        dd7ac793a02553c9c7a14b9715d5a6ad636aa065
Parent:        877c2f2ffb3813e3236a55f07958009633dc8558
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 27 23:23:45 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 30 10:41:51 2018 +0200

aux: enhance teardown to better handle weird names

When 'dmsetup' reports result with --nameprefixes it currently
incorrectly 'escapes' problematic characters.

Letting pass such string though shell 'eval' function is hard task.
So instead cut away substring.

Once dmsetup will start to properly escape backslash and apostrophe
this function may need further tuning.
---
 test/lib/aux.sh |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4269987..fa6309c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -442,19 +442,20 @@ teardown_devs_prefixed() {
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			test "$i" = 0 || sortby="-minor"
 
-			for dm in $(dm_info name,open --separator ';'  --nameprefixes --sort open,"$sortby" -S "name=~$prefix") ; do
+			for dm in $(dm_info name,open --separator ';'  --nameprefixes --unquoted --sort open,"$sortby" -S "name=~$prefix" --mangle none || true) ; do
 				test "$dm" != "No devices found" || break 2
-				eval "$dm"
-
+				DM_NAME=${dm##DM_NAME=}
+				DM_NAME=${DM_NAME%%;DM_OPEN*}
+				DM_OPEN=${dm##*;DM_OPEN=}
 				if test "$i" = 0; then
 					if test "$once" = 1 ; then
 						once=0
 						echo "## removing stray mapped devices with names beginning with $prefix: "
 					fi
 					test "$DM_OPEN" = 0 || break  # stop loop with 1st. opened device
-					dmsetup remove "$DM_NAME" &>/dev/null || touch REMOVE_FAILED &
+					dmsetup remove "$DM_NAME" --mangle none || true # &>/dev/null || touch REMOVE_FAILED &
 				else
-					dmsetup remove -f "$DM_NAME" || true
+					dmsetup remove -f "$DM_NAME" --mangle none || true
 				fi
 
 				num_devs=$(( num_devs + 1 ))


