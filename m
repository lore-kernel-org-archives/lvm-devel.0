From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 14 Jul 2016 12:35:51 +0000 (UTC)
Subject: master - lvmdump: include major and minor numbers for pvs and lvs reports
Message-ID: <20160714123551.DA7B26055D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07be2b864f131f2ec48fe2a22e0a50ea76dd5a70
Commit:        07be2b864f131f2ec48fe2a22e0a50ea76dd5a70
Parent:        4e1bf7acd39e2e6686f634be29b2c64a0aab705c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 14 14:33:33 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 14 14:33:33 2016 +0200

lvmdump: include major and minor numbers for pvs and lvs reports

Including major and minor numbers in pvs and lvs output when calling
lvmdump -a makes it a bit easier to match these items with possible
system log/journal.
---
 scripts/lvmdump.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index bfe79d9..d13a69b 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -142,10 +142,10 @@ if (( $advanced )); then
 	log "\"$LVM\" pvscan -v >> \"$dir/pvscan\" 2>> \"$log\""
 
 	myecho "  lvs..."
-	log "\"$LVM\" lvs -a -H -o +devices >> \"$dir/lvs\" 2>> \"$log\""
+	log "\"$LVM\" lvs -a -H -o +devices,kernel_major,kernel_minor >> \"$dir/lvs\" 2>> \"$log\""
 
 	myecho "  pvs..."
-	log "\"$LVM\" pvs -a -v >> \"$dir/pvs\" 2>> \"$log\""
+	log "\"$LVM\" pvs -a -o +major,minor -v >> \"$dir/pvs\" 2>> \"$log\""
 
 	myecho "  vgs..."
 	log "\"$LVM\" vgs -v >> \"$dir/vgs\" 2>> \"$log\""


