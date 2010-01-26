From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 26 Jan 2010 16:18:56 -0500
Subject: [PATCH] lvmtests: Remove unnecessary "dmsetup resume" after "dmsetup create".
Message-ID: <1264540736-12717-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It is not necessary to resume after a create since the create will
create the table and make it active.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/test-utils.sh |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/test-utils.sh b/test/test-utils.sh
index 440cfbd..5b9796b 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -59,7 +59,6 @@ teardown_() {
 
 make_ioerror() {
 	echo 0 10000000 error | dmsetup create ioerror
-	dmsetup resume ioerror
 	ln -s $G_dev_/mapper/ioerror $G_dev_/ioerror
 }
 
@@ -188,7 +187,6 @@ prepare_devs() {
 		devs="$devs $dev"
 		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
 		dmsetup create $name $name.table
-		dmsetup resume $name
 	done
 
     # set up some default names
-- 
1.6.0.6


