From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  5 Dec 2013 15:40:54 +0000 (UTC)
Subject: master - lvmdump: follow symbolic links in /etc/lvm
Message-ID: <20131205154054.2EA0E60DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73a109d434ffb894cda9c7fc6720d1166a9d5bca
Commit:        73a109d434ffb894cda9c7fc6720d1166a9d5bca
Parent:        a344466e26cf7611c84c2548999dc67080e28347
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 5 16:36:45 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 5 16:36:45 2013 +0100

lvmdump: follow symbolic links in /etc/lvm

---
 scripts/lvmdump.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index 641d109..6d9fe6d 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -204,7 +204,8 @@ myecho "Gathering console messages..."
 log "$TAIL -n 75 /var/log/messages >> \"$dir/messages\" 2>> \"$log\""
 
 myecho "Gathering /etc/lvm info..."
-log "$CP -a /etc/lvm \"$dir/lvm\" 2>> \"$log\""
+log "$LS -laR /etc/lvm >> \"$dir/etc_lvm_listing\" 2>> \"$log\""
+log "$CP -RL --preserve=all /etc/lvm \"$dir/lvm\" 2>> \"$log\""
 
 myecho "Gathering /dev listing..."
 log "$LS -laR /dev >> \"$dir/dev_listing\" 2>> \"$log\""
@@ -241,8 +242,8 @@ if (( $udev )); then
 	log "$UDEVADM info --export-db >> \"$udev_dir/db\" 2>> \"$log\""
 	log "$CP -a /etc/udev/udev.conf \"$udev_dir/conf\" 2>> \"$log\""
 	log "$LS -la /lib/udev >> \"$udev_dir/lib_dir\" 2>> \"$log\""
-	log "$CP -aR /etc/udev/rules.d \"$udev_dir/rules_etc\" 2>> \"$log\""
-	log "$CP -aR /lib/udev/rules.d \"$udev_dir/rules_lib\" 2>> \"$log\""
+	log "$CP -RL --preserve=all /etc/udev/rules.d \"$udev_dir/rules_etc\" 2>> \"$log\""
+	log "$CP -RL --preserve=all /lib/udev/rules.d \"$udev_dir/rules_lib\" 2>> \"$log\""
 fi
 
 if (( $lvmetad )); then


