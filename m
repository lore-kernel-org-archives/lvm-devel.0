From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 15 Apr 2014 13:31:58 +0000 (UTC)
Subject: master - lvmdump: add -s to gather system info and context (currently systemd-related only)
Message-ID: <20140415133158.0692F60F5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6763c64a735769991170b64bb2224c861f69f3a
Commit:        a6763c64a735769991170b64bb2224c861f69f3a
Parent:        704609b17ee5c67fec65400ba48841aff70c6d21
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 15 15:27:30 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 15 15:27:30 2014 +0200

lvmdump: add -s to gather system info and context (currently systemd-related only)

This is sort of info we always ask people to retrieve when
inspecting problems in systemd environment so let's have this
as part of lvmdump directly.

The -s option does not need to be bound to systemd only. We could
add support for initscripts or any other system-wide/service tracking
info that can help us with debugging problems.
---
 WHATS_NEW          |    1 +
 man/lvmdump.8.in   |    9 +++++++++
 scripts/lvmdump.sh |   44 ++++++++++++++++++++++++++++++++++++++------
 3 files changed, 48 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f3da48c..c2cb3be 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Add lvmdump -s to collect system info and context (currently systemd only).
   Refactor allocation code to make A_POSITIONAL_FILL explicit.
   Use thread-safe ctime_r() for clvmd debug logging.
   Skip adding replies to already finished reply thread.
diff --git a/man/lvmdump.8.in b/man/lvmdump.8.in
index 5e355de..a34e062 100644
--- a/man/lvmdump.8.in
+++ b/man/lvmdump.8.in
@@ -10,6 +10,7 @@ lvmdump - create lvm2 information dumps for diagnostic purposes
 .RB [ \-h ]
 .RB [ \-l ]
 .RB [ \-m ]
+.RB [ \-s ]
 .RB [ \-u ]
 .SH DESCRIPTION
 lvmdump is a tool to dump various information concerning LVM2.
@@ -40,6 +41,8 @@ The content of the tarball is as follows:
 .br
 - if enabled with \-l, lvmetad state if running
 .br
+- if enabled with \-s, system info and context
+.br
 - if enabled with \-u, udev info and context
 .SH OPTIONS
 .TP
@@ -72,6 +75,12 @@ This option generates a 1:1 dump of the metadata area from all PVs visible
 to the system, which can cause the dump to increase in size considerably.
 However, the metadata dump may represent a valuable diagnostic resource.
 .TP
+.B \-s
+Gather system info and context. Currently, this encompasses systemd info
+and context only: overall state of systemd units present in the system,
+more detailed status of units controlling LVM functionality and the content
+of systemd journal for current boot.
+.TP
 .B \-u
 Gather udev info and context: /etc/udev/udev.conf file, udev daemon version
 (output of 'udevadm info --version' command), udev rules currently used in the system
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 46ba8cf..b8f73f3 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -56,11 +56,12 @@ function usage {
 	echo "    -h print this message"
 	echo "    -a advanced collection - warning: if lvm is already hung,"
 	echo "       then this script may hang as well if -a is used"
-	echo "    -m gather LVM metadata from the PVs"
-	echo "    -d <directory> dump into a directory instead of tarball"
 	echo "    -c if running clvmd, gather cluster data as well"
-	echo "    -u gather udev info and context"
+	echo "    -d <directory> dump into a directory instead of tarball"
 	echo "    -l gather lvmetad state if running"
+	echo "    -m gather LVM metadata from the PVs"
+	echo "    -s gather system info and context"
+	echo "    -u gather udev info and context"
 	echo ""
 
 	exit 1
@@ -69,17 +70,18 @@ function usage {
 advanced=0
 clustered=0
 metadata=0
+sysreport=0
 udev=0
-while getopts :acd:hmul opt; do
+while getopts :acd:hlmus opt; do
 	case $opt in 
-		s)      sysreport=1 ;;
 		a)	advanced=1 ;;
 		c)	clustered=1 ;;
 		d)	userdir=$OPTARG ;;
 		h)	usage ;;
+		l)	lvmetad=1 ;;
 		m)	metadata=1 ;;
+		s)      sysreport=1 ;;
 		u)	udev=1 ;;
-		l)	lvmetad=1 ;;
 		:)	echo "$0: $OPTARG requires a value:"; usage ;;
 		\?)     echo "$0: unknown option $OPTARG"; usage ;;
 		*)	usage ;;
@@ -234,6 +236,36 @@ if (( $metadata )); then
 	done
 fi
 
+if (( $sysreport )); then
+	myecho "Gathering system info..."
+
+	sysreport_dir="$dir/sysreport"
+	log_lines=10000
+
+	SYSTEMCTL=$(which systemctl 2>> $log)
+	JOURNALCTL=$(which journalctl 2>> $log)
+
+	if test -z "$SYSTEMCTL"; then
+		myecho "WARNING: systemctl not found"
+	elif test -z "$JOURNALCTL"; then
+		myecho "WARNING: journalctl not found"
+	else
+		log "$MKDIR -p \"$sysreport_dir\""
+		log "$JOURNALCTL -b --no-pager -o short-precise > \"$sysreport_dir/journal_content\" 2>> \"$log\""
+		log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise dm-event.socket dm-event.service \
+						   lvm2-monitor.service \
+						   lvm2-lvmetad.socket lvm2-lvmetad.service \
+						   lvm2-cluster-activation.service \
+						   lvm2-clvmd.service \
+						   lvm2-cmirrord.service \
+						   > \"$sysreport_dir/systemd_lvm2_services_status\" 2>> \"$log\""
+		log "$SYSTEMCTL list-units -l --no-legend --no-pager > \"$sysreport_dir/systemd_unit_list\" 2>> \"$log\""
+		for unit in $(cat $sysreport_dir/systemd_unit_list | grep lvm2-pvscan | cut -d " " -f 1); do
+			log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise $unit >> \"$sysreport_dir/systemd_lvm2_pvscan_service_status\""
+		done
+	fi
+fi
+
 if (( $udev )); then
 	myecho "Gathering udev info..."
 


