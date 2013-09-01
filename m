From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  1 Sep 2013 20:41:22 +0000 (UTC)
Subject: master - tests: add delay_dev
Message-ID: <20130901204122.C7E9860EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7cc36a93f6b4a9648f430e32973ea882e3c0e7c7
Commit:        7cc36a93f6b4a9648f430e32973ea882e3c0e7c7
Parent:        350cf7968c77d090b49fc41761221da930d60538
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 30 14:50:58 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Aug 31 21:40:51 2013 +0200

tests: add delay_dev

Function to create slower responsive device.

Useful for testing things which needs to happen something during on
going operation - with  'delayed' device - much smaller sizes of devices
are needed and its much more deterministic (though still not optimal)
---
 test/lib/aux.sh |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 36de6e5..c9bb1fb 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -342,6 +342,35 @@ prepare_devs() {
 	echo "ok"
 }
 
+# Replace linear PV device with its 'delayed' version
+# Could be used to more deterministicaly hit some problems.
+# Parameters: {device path} [read delay ms] [write delay ms]
+# Original device is restored when both delay params are 0 (or missing).
+# i.e.  delay_dev "$dev1" 0 200
+delay_dev() {
+	target_at_least dm-delay 1 2 0 || skip
+	local name=$(echo "$1" | sed -e 's,.*/,,')
+	local read_ms=${2:-0}
+	local write_ms=${3:-0}
+	local pos
+	local size
+	local type
+	local pvdev
+	local offset
+
+	read pos size type pvdev offset < "$name.table"
+
+	init_udev_transaction
+	if test $read_ms -ne 0 -o $write_ms -ne 0 ; then
+		echo "0 $size delay $pvdev $offset $read_ms $pvdev $offset $write_ms" | \
+			dmsetup load "$name"
+	else
+		dmsetup load "$name" "$name.table"
+	fi
+	dmsetup resume "$name"
+	finish_udev_transaction
+}
+
 disable_dev() {
 	local dev
 


