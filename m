From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:34 +0000 (UTC)
Subject: master - tests: add device holding function
Message-ID: <20161222223834.57675611D0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e1943fc07f81e1c824757ccdac45c1e43a57af28
Commit:        e1943fc07f81e1c824757ccdac45c1e43a57af28
Parent:        1053d46aff11a8e592ca91ba56d6400f4693b9a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 22 22:21:09 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

tests: add device holding function

Hold device open with sleep and wait till sleep really opens
given devices.
---
 test/lib/aux.sh |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a195883..174e05e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1491,6 +1491,27 @@ wait_pvmove_lv_ready() {
 	fi
 }
 
+# Holds device open with sleep which automatically expires after given timeout
+# Prints  PID of running holding sleep process in background
+hold_device_open() {
+	local vgname=$1
+	local lvname=$2
+	local sec=${3:-20} # default 20sec
+
+	sleep $sec < "$DM_DEV_DIR/$vgname/$lvname" >/dev/null 2>&1 &
+	SLEEP_PID=$!
+	# wait till device is openned
+	for i in $(seq 1 50) ; do
+		if test "$(dmsetup info --noheadings -c -o open $vgname-$lvname)" -ne 0 ; then
+			echo "$SLEEP_PID"
+			return
+		fi
+		sleep .1
+	done
+
+	die "$vgname-$lvname expected to be openned, but it's not!"
+}
+
 # return total memory size in kB units
 total_mem() {
 	while IFS=":" read -r a b ; do


