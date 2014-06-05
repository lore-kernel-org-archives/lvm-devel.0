From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jun 2014 15:54:31 +0000 (UTC)
Subject: master - tests: use shell arrays to keep device names
Message-ID: <20140605155431.0277F6025E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=223bdc5eb2fe69c43e0138bf097c33f1fa83d536
Commit:        223bdc5eb2fe69c43e0138bf097c33f1fa83d536
Parent:        21db25b3c41dec54da2a6975bf3f3f52b151f1e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 4 13:46:19 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:49:34 2014 +0200

tests: use shell arrays to keep device names

Better preserving spaces in device path name,
though admitely rest of test suite need
more repairs...
---
 test/lib/aux.sh |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 9a13cc8..b093e3c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -349,13 +349,13 @@ prepare_devs() {
 	fi
 
 	local size=$(($loopsz/$n))
-	devs=
-
+	local count=0
 	init_udev_transaction
 	for i in $(seq 1 $n); do
 		local name="${PREFIX}$pvname$i"
 		local dev="$DM_DEV_DIR/mapper/$name"
-		devs="$devs $dev"
+		DEVICES[$count]=$dev
+		count=$(( $count + 1 ))
 		echo 0 $size linear "$LOOP" $((($i-1)*$size)) > "$name.table"
 		dmsetup create -u "TEST-$name" "$name" "$name.table"
 	done
@@ -370,7 +370,8 @@ prepare_devs() {
 	#	dmsetup table $name
 	#done
 
-	echo $devs > DEVICES
+	printf "%s\n" "${DEVICES[@]}" > DEVICES
+#	( IFS=$'\n'; echo "${DEVICES[*]}" ) >DEVICES
 	echo "ok"
 }
 
@@ -502,14 +503,14 @@ restore_dev() {
 
 prepare_pvs() {
 	prepare_devs "$@"
-	pvcreate -ff $devs
+	pvcreate -ff "${DEVICES[@]}"
 }
 
 prepare_vg() {
 	teardown_devs
 
 	prepare_pvs "$@"
-	vgcreate -s 512K $vg $devs
+	vgcreate -s 512K $vg "${DEVICES[@]}"
 }
 
 extend_filter() {


