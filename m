From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Mar 2018 12:25:46 -0400
Subject: master - fsadm: shellcheck prefer explicit escaping
Message-ID: <201803231625.w2NGPkpH031927@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cafcc5813ac958798d5dce19b1b65a9941cc39ad
Commit:        cafcc5813ac958798d5dce19b1b65a9941cc39ad
Parent:        fe69731d31648af24383515c1c3bc323551d75e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 23 15:53:36 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 23 17:25:00 2018 +0100

fsadm: shellcheck prefer explicit escaping

Backslash is literal in "\t". Prefer explicit escaping: "\\t".
---
 scripts/fsadm.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index a09b915..28ca670 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -311,10 +311,10 @@ detect_mounted_with_proc_self_mountinfo() {
 # device (which could have been renamed).
 # We need to visit every mount point and check it's major minor
 detect_mounted_with_proc_mounts() {
-	MOUNTED=$("$GREP" "^$VOLUME[ \t]" "$PROCMOUNTS")
+	MOUNTED=$("$GREP" "^$VOLUME[ \\t]" "$PROCMOUNTS")
 
 	# for empty string try again with real volume name
-	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \t]" "$PROCMOUNTS")
+	test -z "$MOUNTED" && MOUNTED=$("$GREP" "^$RVOLUME[ \\t]" "$PROCMOUNTS")
 
 	MOUNTDEV=$(echo -n -e "${MOUNTED%% *}")
 	# cut device name prefix and trim everything past mountpoint
@@ -325,8 +325,8 @@ detect_mounted_with_proc_mounts() {
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
 		# will not work with spaces in paths
-		MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
-		test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
+		MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$VOLUME[ \\t]")
+		test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$RVOLUME[ \\t]")
 		MOUNTDEV=${MOUNTED%% on *}
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name


