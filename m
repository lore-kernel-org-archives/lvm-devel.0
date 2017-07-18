From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 18 Jul 2017 15:25:44 -0400
Subject: master - tests: aus.sh better defaults
Message-ID: <201707181925.v6IJPibm005539@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43dbfee32a0758c84b54aff41d1f91b2c974117f
Commit:        43dbfee32a0758c84b54aff41d1f91b2c974117f
Parent:        466da710e03149187c05dcfd598aa66c32158496
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 18 21:25:03 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 18 21:25:03 2017 +0200

tests: aus.sh better defaults

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 93345bf..7ab3885 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1563,7 +1563,7 @@ check_lvmpolld_init_rq_count() {
 
 wait_pvmove_lv_ready() {
 	# given sleep .1 this is about 60 secs of waiting
-	local retries=${2:-300}
+	local retries=${2-300}
 
 	if [ -e LOCAL_LVMPOLLD ]; then
 		local lvid=""
@@ -1597,7 +1597,7 @@ wait_pvmove_lv_ready() {
 hold_device_open() {
 	local vgname=$1
 	local lvname=$2
-	local sec=${3:-20} # default 20sec
+	local sec=${3-20} # default 20sec
 
 	sleep "$sec" < "$DM_DEV_DIR/$vgname/$lvname" >/dev/null 2>&1 &
 	SLEEP_PID=$!


