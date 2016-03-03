From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:39 +0000 (UTC)
Subject: master - lvmdump: also list historical LVs in lvmdump
Message-ID: <20160303132039.D48E860310@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b39473a537249b60e36f69e28155bfc6829763ab
Commit:        b39473a537249b60e36f69e28155bfc6829763ab
Parent:        8a601454e178c72b39be66365eaa153d69d4ed40
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 3 10:36:58 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

lvmdump: also list historical LVs in lvmdump

---
 scripts/lvmdump.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvmdump.sh b/scripts/lvmdump.sh
index bf72d65..1e91a9d 100755
--- a/scripts/lvmdump.sh
+++ b/scripts/lvmdump.sh
@@ -137,7 +137,7 @@ if (( $advanced )); then
 	log "\"$LVM\" pvscan -v >> \"$dir/pvscan\" 2>> \"$log\""
 
 	myecho "  lvs..."
-	log "\"$LVM\" lvs -a -o +devices >> \"$dir/lvs\" 2>> \"$log\""
+	log "\"$LVM\" lvs -a -H -o +devices >> \"$dir/lvs\" 2>> \"$log\""
 
 	myecho "  pvs..."
 	log "\"$LVM\" pvs -a -v >> \"$dir/pvs\" 2>> \"$log\""


