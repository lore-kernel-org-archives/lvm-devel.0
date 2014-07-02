From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 13:12:20 +0000 (UTC)
Subject: master - tests: ensure data hits cow
Message-ID: <20140702131220.4978C61006@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6811dd51218e88467d91a1b2b309bbfed5eaf0e
Commit:        c6811dd51218e88467d91a1b2b309bbfed5eaf0e
Parent:        39bd6bb89e364e72808870e2ad88ddf79b591a3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 2 15:02:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 15:10:10 2014 +0200

tests: ensure data hits cow

---
 test/shell/lvextend-snapshot-dmeventd.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index af8a927..3d9ce1f 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -17,6 +17,7 @@ extend() {
 
 write_() {
 	dd if=/dev/zero of="$DM_DEV_DIR/$vg/snap" bs=1k count=$2 seek=$1
+	sync
 }
 
 percent_() {


