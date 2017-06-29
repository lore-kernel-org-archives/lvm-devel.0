From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:09 -0400
Subject: master - fsadm: split local var dev
Message-ID: <201706292025.v5TKP9i3025625@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05a6d43476a4b2600329eae444c980107494b4ac
Commit:        05a6d43476a4b2600329eae444c980107494b4ac
Parent:        439aaca3bc42c73ffe99bbf9b15c726b987ee2a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 16:02:13 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

fsadm: split local var dev

Split defining of local variables from being them
assigned at the same time (lossing error code).
---
 scripts/fsadm.sh |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index f3cc98b..b8744b1 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -229,8 +229,10 @@ detect_fs() {
 # Check that passed mounted MAJOR:MINOR is not matching $MAJOR:MINOR of resized $VOLUME
 validate_mounted_major_minor() {
 	test "$1" = "$MAJORMINOR" || {
-		local REFNAME=$(dmsetup info -c -j "${1%%:*}" -m "${1##*:}" -o name --noheadings 2>/dev/null)
-		local CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings 2>/dev/null)
+		local REFNAME
+		local CURNAME
+		REFNAME=$(dmsetup info -c -j "${1%%:*}" -m "${1##*:}" -o name --noheadings 2>/dev/null)
+		CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings 2>/dev/null)
 		error "Cannot ${CHECK+CHECK}${RESIZE+RESIZE} device \"$VOLUME\" without umounting filesystem $MOUNTED first." \
 		      "Mounted filesystem is using device $CURNAME, but referenced device is $REFNAME." \
 		      "Filesystem utilities currently do not support renamed devices."
@@ -243,10 +245,12 @@ validate_mounted_major_minor() {
 # abort further command processing
 check_valid_mounted_device() {
 	local MOUNTEDMAJORMINOR
-	local VOL=$("$READLINK" $READLINK_E "$1")
-	local CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings)
+	local VOL
+	local CURNAME
 	local SUGGEST="Possibly device \"$1\" has been renamed to \"$CURNAME\"?"
 
+	VOL=$("$READLINK" $READLINK_E "$1")
+	CURNAME=$(dmsetup info -c -j "$MAJOR" -m "$MINOR" -o name --noheadings)
 	# more confused, device is not DM....
 	test -n "$CURNAME" || SUGGEST="Mounted volume is not a device mapper device???"
 


