From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 22 Jan 2013 10:33:00 +0000 (UTC)
Subject: master - locales: use higher prio LC_ALL variable
Message-ID: <20130122103300.36157A0E0B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bcc1da2f3f8e5f62af7b9e3a0967f7d1a60b582
Commit:        8bcc1da2f3f8e5f62af7b9e3a0967f7d1a60b582
Parent:        142c4bf9f04a46daf1c3d94581b43ec7c481ba59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 22 11:25:02 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 22 11:25:02 2013 +0100

locales: use higher prio LC_ALL variable

For reseting locale environment into significantly less memory
consuming version 'C' - use LC_ALL instead of LANG since it has
higher priority in locale settings.

Otherwise we may observe whole locale-archive which might be
over 100MB on i.e. Fedora systems locked in memory with
some daemons.
---
 WHATS_NEW                        |    1 +
 daemons/clvmd/clvmd.c            |    4 ++--
 daemons/dmeventd/dmeventd.c      |    4 ++--
 libdaemon/server/daemon-server.c |    4 ++--
 scripts/fsadm.sh                 |   14 +++++++-------
 5 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 987cefa..11afee7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Set locales with LC_ALL instead of lower priority LANG variable.
   Fix a crash-inducing race condition in lvmetad.
   Add log/debug_classes to lvm.conf to control debug log messages.
   Synchronize with udev in pvscan --cache and fix dangling udev_sync cookies.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 398e1a4..54cf1ac 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -440,8 +440,8 @@ int main(int argc, char *argv[])
 	 * used by some glibc (on some distributions it takes over 100MB).
 	 * Daemon currently needs to use mlockall().
 	 */
-	if (setenv("LANG", "C", 1))
-		perror("Cannot set LANG to C");
+	if (setenv("LC_ALL", "C", 1))
+		perror("Cannot set LC_ALL to C");
 
 	/* Setting debug options on an existing clvmd */
 	if (debug_opt && !check_local_clvmd()) {
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 5f2339f..55b940f 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1965,8 +1965,8 @@ int main(int argc, char *argv[])
 	 * used by some glibc (on some distributions it takes over 100MB).
 	 * Daemon currently needs to use mlockall().
 	 */
-	if (setenv("LANG", "C", 1))
-		perror("Cannot set LANG to C");
+	if (setenv("LC_ALL", "C", 1))
+		perror("Cannot set LC_ALL to C");
 
 	if (_restart)
 		restart();
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 0237465..735a0ea 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -456,8 +456,8 @@ void daemon_start(daemon_state s)
 	 * some glibc (on some distributions it takes over 100MB). Some daemons
 	 * need to use mlockall().
 	 */
-	if (setenv("LANG", "C", 1))
-		perror("Cannot set LANG to C");
+	if (setenv("LC_ALL", "C", 1))
+		perror("Cannot set LC_ALL to C");
 
 #ifdef linux
 	_systemd_activation = _systemd_handover(&s);
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 4624a1c..1e8a22a 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -213,8 +213,8 @@ detect_mounted()  {
 
 	# for systems with different device names - check also mount output
 	if test -z "$MOUNTED" ; then
-		MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
-		test -z "$MOUNTED" && MOUNTED=$(LANG=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
+		MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$VOLUME[ \t]")
+		test -z "$MOUNTED" && MOUNTED=$(LC_ALL=C "$MOUNT" | "$GREP" "^$RVOLUME[ \t]")
 		MOUNTED=${MOUNTED##* on }
 		MOUNTED=${MOUNTED% type *} # allow type in the mount name
 	fi
@@ -283,7 +283,7 @@ validate_parsing() {
 ####################################
 resize_ext() {
 	verbose "Parsing $TUNE_EXT -l \"$VOLUME\""
-	for i in $(LANG=C "$TUNE_EXT" -l "$VOLUME"); do
+	for i in $(LC_ALL=C "$TUNE_EXT" -l "$VOLUME"); do
 		case "$i" in
 		  "Block size"*) BLOCKSIZE=${i##*  } ;;
 		  "Block count"*) BLOCKCOUNT=${i##*  } ;;
@@ -318,7 +318,7 @@ resize_reiser() {
 	detect_mounted && verbose "ReiserFS resizes only unmounted filesystem" && try_umount
 	REMOUNT=$MOUNTED
 	verbose "Parsing $TUNE_REISER \"$VOLUME\""
-	for i in $(LANG=C "$TUNE_REISER" "$VOLUME"); do
+	for i in $(LC_ALL=C "$TUNE_REISER" "$VOLUME"); do
 		case "$i" in
 		  "Blocksize"*) BLOCKSIZE=${i##*: } ;;
 		  "Count of blocks"*) BLOCKCOUNT=${i##*: } ;;
@@ -347,7 +347,7 @@ resize_xfs() {
 		temp_mount || error "Cannot mount Xfs filesystem"
 	fi
 	verbose "Parsing $TUNE_XFS \"$MOUNTPOINT\""
-	for i in $(LANG=C "$TUNE_XFS" "$MOUNTPOINT"); do
+	for i in $(LC_ALL=C "$TUNE_XFS" "$MOUNTPOINT"); do
 		case "$i" in
 		  "data"*) BLOCKSIZE=${i##*bsize=} ; BLOCKCOUNT=${i##*blocks=} ;;
 		esac
@@ -389,7 +389,7 @@ resize() {
 
 ####################################
 # Calclulate diff between two dates
-#  LANG=C input is expected the
+#  LC_ALL=C input is expected the
 #  only one supported
 ####################################
 diff_dates() {
@@ -410,7 +410,7 @@ check() {
 	  "ext2"|"ext3"|"ext4")
 		IFS_CHECK=$IFS
 		IFS=$NL
-		for i in $(LANG=C "$TUNE_EXT" -l "$VOLUME"); do
+		for i in $(LC_ALL=C "$TUNE_EXT" -l "$VOLUME"); do
 			case "$i" in
 			  "Last mount"*) LASTMOUNT=${i##*: } ;;
 			  "Last checked"*) LASTCHECKED=${i##*: } ;;


