From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 25 Mar 2014 12:08:42 +0000 (UTC)
Subject: master - lvmdump: add lvm dumpconfig --type diff/missing
Message-ID: <20140325120842.D939660EE5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ce78cb58eb84c24c4ba31167f7b7fc03301b454b
Commit:        ce78cb58eb84c24c4ba31167f7b7fc03301b454b
Parent:        0738f0ad7289cca4121aace1540e479648a1abe2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 25 13:06:59 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 25 13:06:59 2014 +0100

lvmdump: add lvm dumpconfig --type diff/missing

For a quick overview of config when debugging and to quickly check
which values are different from defaults and which are not defined
in the config and for which defaults are used.
---
 WHATS_NEW          |    1 +
 scripts/lvmdump.sh |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6926901..e6fa1d7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Include 'lvm dumpconfig --type missing' and '--type diff' output to lvmdump.
   Return failure when specifying negative size for pvresize.
   Fix memory corruption in cmd context refresh if clvmd leaks opened device.
   Reinitialise lvmcache properly on fork to fix premature polldaemon exit.
diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 6d9fe6d..46ba8cf 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -206,6 +206,8 @@ log "$TAIL -n 75 /var/log/messages >> \"$dir/messages\" 2>> \"$log\""
 myecho "Gathering /etc/lvm info..."
 log "$LS -laR /etc/lvm >> \"$dir/etc_lvm_listing\" 2>> \"$log\""
 log "$CP -RL --preserve=all /etc/lvm \"$dir/lvm\" 2>> \"$log\""
+log "$LVM dumpconfig --type diff --file \"$dir/config_diff\" 2>> \"$log\""
+log "$LVM dumpconfig --type missing --file \"$dir/config_missing\" 2>> \"$log\""
 
 myecho "Gathering /dev listing..."
 log "$LS -laR /dev >> \"$dir/dev_listing\" 2>> \"$log\""


