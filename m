From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Sep 2022 12:59:06 +0000 (GMT)
Subject: main - tests: validate CONFIG_HZ_1000
Message-ID: <20220921125906.CA32C3855148@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a7aeebf7d7c58e53158321d73542c239896a3d7
Commit:        3a7aeebf7d7c58e53158321d73542c239896a3d7
Parent:        96f303eb08d6429e92d727020788830a3f7fcfc8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 21 14:44:05 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 21 14:58:34 2022 +0200

tests: validate CONFIG_HZ_1000

If we plan to use dm throttling for mirror targets - we actually
have to check whether kernel runs with CONFIG_HZ_1000 - if it does
not the whole idea of throttling is actually not working in the
testsuite as within a single 'tick' with HZ 100 way too much date
is being moved on any modern hardware - and since there is no plan
to change this in kernel - we simply avoid using throttling on such
kernel and test needs to work differently - either ignore results
or use much larger mirror sizes...
---
 test/lib/aux.sh | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ca9406383..58439d62d 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1206,6 +1206,16 @@ remove_dm_devs() {
 # Throttle down performance of kcopyd when mirroring i.e. disk image
 throttle_sys="/sys/module/dm_mirror/parameters/raid1_resync_throttle"
 throttle_dm_mirror() {
+	# if the kernel config file is present, validate whether the kernel uses HZ_1000
+	# and return failure for this 'throttling' when it does NOT as without this setting
+	# whole throttling is pointless on modern hardware
+	local kconfig="/boot/config-$(uname -r)"
+	if test -e "$kconfig" ; then
+		grep -q "CONFIG_HZ_1000=y" "$kconfig" 2>/dev/null || {
+			echo "WARNING: CONFIG_HZ_1000=y is NOT set in $kconfig -> throttling is unusable"
+			return 1
+		}
+	fi
 	test -e "$throttle_sys" || return
 	test -f THROTTLE || cat "$throttle_sys" > THROTTLE
 	echo ${1-1} > "$throttle_sys"

