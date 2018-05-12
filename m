From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:25:51 -0400
Subject: master - tests: aux support throttling of dm mirror
Message-ID: <201805121625.w4CGPpx6007832@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=172d8fb3554c3c71ce4ba0d8efa65dce62a877c3
Commit:        172d8fb3554c3c71ce4ba0d8efa65dce62a877c3
Parent:        0cadfdd69dabcb76cab575d790233a36b763633a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 7 11:39:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: aux support throttling of dm mirror

Usage of dm_delay looks to be slowing not just 'delayed' portion
of device, but due to the fact it's also slows down ANY flush
operation on such device it's overal speed impact is huge.

In some case we can however user other methods to slowdown disk writes,
in case of old dm 'mirror'  target we can throttle  I/O of mirror
synchronisation giving the next commands enough time to test couple
race conditions.

Usage:

throttle_dm_mirror [percentage]

Thtrottle down sync speed (lowest is '1' which is also default when
unspecified)

restore_dm_mirror

Restores the value of throttling before call of  'throttle_dm_mirror'
Usually it should '100'
---
 test/lib/aux.sh |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1f83a00..853a78f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -503,6 +503,7 @@ teardown_devs() {
 			udev_wait
 		}
 	}
+	restore_dm_mirror
 }
 
 kill_sleep_kill_() {
@@ -1054,6 +1055,22 @@ enable_dev() {
 	done
 }
 
+# Throttle down performance of kcopyd when mirroring i.e. disk image
+throttle_sys="/sys/module/dm_mirror/parameters/raid1_resync_throttle"
+throttle_dm_mirror() {
+	test -f THROTTLE || cat "$throttle_sys" > THROTTLE
+	echo ${1-1} > "$throttle_sys"
+}
+
+# Restore original kcopyd throttle value and have mirroring fast again
+restore_dm_mirror() {
+	test ! -f THROTTLE || {
+		cat THROTTLE > "$throttle_sys"
+		rm -f THROTTLE
+	}
+}
+
+
 # Once there is $name.devtable
 # this is a quick way to restore to this table entry
 restore_from_devtable() {


