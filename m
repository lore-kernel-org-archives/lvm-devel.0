From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Oct 2012 20:47:51 +0000 (UTC)
Subject: master - lvmdump: Add -l, to collect a state dump from lvmetad.
Message-ID: <20121011204751.BDFD61D41@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4022fd3e79099fb22b2b7d3d6dca8de733a2a783
Commit:        4022fd3e79099fb22b2b7d3d6dca8de733a2a783
Parent:        8557b412f679f1a9c8edb91e43b35793645c901e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Oct 11 22:42:20 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Oct 11 22:42:20 2012 +0200

lvmdump: Add -l, to collect a state dump from lvmetad.

---
 scripts/lvmdump.sh |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 5901892..641d109 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -33,11 +33,14 @@ BASENAME=basename
 UDEVADM=udevadm
 UNAME=uname
 TR=tr
+SOCAT=socat # either socat or nc is needed for dumping lvmetad state
+NC=nc
 
 # user may override lvm and dmsetup location by setting LVM_BINARY
 # and DMSETUP_BINARY respectively
 LVM=${LVM_BINARY-lvm}
 DMSETUP=${DMSETUP_BINARY-dmsetup}
+LVMETAD_SOCKET=${LVM_LVMETAD_SOCKET-/var/run/lvm/lvmetad.socket}
 
 die() {
     code=$1; shift
@@ -57,6 +60,7 @@ function usage {
 	echo "    -d <directory> dump into a directory instead of tarball"
 	echo "    -c if running clvmd, gather cluster data as well"
 	echo "    -u gather udev info and context"
+	echo "    -l gather lvmetad state if running"
 	echo ""
 
 	exit 1
@@ -66,7 +70,7 @@ advanced=0
 clustered=0
 metadata=0
 udev=0
-while getopts :acd:hmu opt; do
+while getopts :acd:hmul opt; do
 	case $opt in 
 		s)      sysreport=1 ;;
 		a)	advanced=1 ;;
@@ -75,6 +79,7 @@ while getopts :acd:hmu opt; do
 		h)	usage ;;
 		m)	metadata=1 ;;
 		u)	udev=1 ;;
+		l)	lvmetad=1 ;;
 		:)	echo "$0: $OPTARG requires a value:"; usage ;;
 		\?)     echo "$0: unknown option $OPTARG"; usage ;;
 		*)	usage ;;
@@ -240,6 +245,22 @@ if (( $udev )); then
 	log "$CP -aR /lib/udev/rules.d \"$udev_dir/rules_lib\" 2>> \"$log\""
 fi
 
+if (( $lvmetad )); then
+    (echo 'request="dump"'; echo '##') | {
+	if type -p $SOCAT >& /dev/null; then
+	    echo "$SOCAT unix-connect:$LVMETAD_SOCKET -" >> "$log"
+	    $SOCAT "unix-connect:$LVMETAD_SOCKET" - 2>> "$log"
+	elif echo | $NC -U "$LVMETAD_SOCKET"; then
+	    echo "$NC -U $LVMETAD_SOCKET" >> "$log"
+	    $NC -U "$LVMETAD_SOCKET" 2>> "$log"
+	else
+	    myecho "WARNING: Neither socat nor nc -U seems to be available." 1>&2
+	    echo "# DUMP FAILED"
+	    return 1
+	fi
+    } > "$dir/lvmetad.txt"
+fi
+
 if test -z "$userdir"; then
 	lvm_dump="$dirbase.tgz"
 	myecho "Creating report tarball in $HOME/$lvm_dump..."


