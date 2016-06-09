From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  9 Jun 2016 11:54:49 +0000 (UTC)
Subject: master - lvmdump: also collect output from lsblk command when running lvmdump -s
Message-ID: <20160609115449.427FD60F20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cfdc87b62331875c2f10cca2c41f486d40b2a67c
Commit:        cfdc87b62331875c2f10cca2c41f486d40b2a67c
Parent:        86f92714574487cce6a9de785ba2ff93b23a98f7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 9 13:51:09 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 9 13:54:15 2016 +0200

lvmdump: also collect output from lsblk command when running lvmdump -s

lsblk provides nice and quick overview of the storage/sysfs structure
that is useful for debugging - collect its output when running lvmdump -s.
---
 WHATS_NEW          |    1 +
 man/lvmdump.8.in   |    9 +++++----
 scripts/lvmdump.sh |   11 ++++++++++-
 3 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2e7e138..0afd527 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.156 - 
 ================================
+  If available, also collect output from lsblk command when running lvmdump -s.
   Fix regression in blkdeactivate causing dm and md devices to be skipped. (2.02.155)
 
 Version 2.02.155 - 3rd June 2016
diff --git a/man/lvmdump.8.in b/man/lvmdump.8.in
index f9c2284..d0e102e 100644
--- a/man/lvmdump.8.in
+++ b/man/lvmdump.8.in
@@ -85,10 +85,11 @@ history for all yet uncollected results of polling operations already finished
 including reason.
 .TP
 .B \-s
-Gather system info and context. Currently, this encompasses systemd info
-and context only: overall state of systemd units present in the system,
-more detailed status of units controlling LVM functionality and the content
-of systemd journal for current boot.
+Gather system info and context. Currently, this encompasses info gathered
+by calling lsblk command and various systemd info and context: overall state
+of systemd units present in the system, more detailed status of units
+controlling LVM functionality and the content of systemd journal for
+current boot.
 .TP
 .B \-u
 Gather udev info and context: /etc/udev/udev.conf file, udev daemon version
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index a813537..bfe79d9 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -252,13 +252,22 @@ if (( $sysreport )); then
 
 	SYSTEMCTL=$(which systemctl 2>> $log)
 	JOURNALCTL=$(which journalctl 2>> $log)
+	LSBLK=$(which lsblk 2>> $log)
+
+	log "$MKDIR -p \"$sysreport_dir\""
+
+	if test -z "LSBLK"; then
+		myecho "WARNING: lsblk not found"
+	else
+		log "$LSBLK -O >> \"$sysreport_dir/lsblk\""
+		log "$LSBLK -s >> \"$sysreport_dir/lsblk_s\""
+	fi
 
 	if test -z "$SYSTEMCTL"; then
 		myecho "WARNING: systemctl not found"
 	elif test -z "$JOURNALCTL"; then
 		myecho "WARNING: journalctl not found"
 	else
-		log "$MKDIR -p \"$sysreport_dir\""
 		log "$JOURNALCTL -b --no-pager -o short-precise > \"$sysreport_dir/journal_content\" 2>> \"$log\""
 		log "$SYSTEMCTL status -l --no-pager -n $log_lines -o short-precise dm-event.socket dm-event.service \
 						   lvm2-monitor.service \


