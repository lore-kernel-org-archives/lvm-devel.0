From: David Teigland <teigland@sourceware.org>
Date: Thu, 26 Sep 2019 11:46:38 -0400
Subject: master - tests: writecache-split check have_writecache
Message-ID: <201909261546.x8QFkc6a032548@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0673d13518ac7d058ca70b04c29fd30f4fedeab6
Commit:        0673d13518ac7d058ca70b04c29fd30f4fedeab6
Parent:        90fe4b106b1e13a2d1244951710d642761f2fd16
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 26 10:45:53 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 26 10:45:53 2019 -0500

tests: writecache-split check have_writecache

---
 test/shell/writecache-split.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index b28cec9..6a7a2cd 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -45,7 +45,7 @@ mount_umount()
         lvchange -an $vg/$lvt
 }
 
-aux have_cache 1 10 0 || skip
+aux have_writecache 1 0 0 || skip
 which mkfs.xfs || skip
 
 mount_dir="mnt"


