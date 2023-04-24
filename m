From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 24 Apr 2023 22:14:33 +0000 (GMT)
Subject: main - aux: use unused brd device for testing
Message-ID: <20230424221433.EE42F3858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a51b6d5e4269ba4a5b335a3894873c750c2e8384
Commit:        a51b6d5e4269ba4a5b335a3894873c750c2e8384
Parent:        5e4c0701d9d37eaa46468319c4df8f221acd38b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 24 23:46:50 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 00:12:31 2023 +0200

aux: use unused brd device for testing

When 'brd' device can be removed (is unused AKA not opened),
remove such device and use again for testing.

Let's assume user has no unused brd device left in the system.

When the 'tests' sometimes fail to cleanup devices, with this
change futher cleanup from some next test may evenually release
brd device and make it available for testing.
---
 test/lib/aux.sh | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8b04e1d30..b2660b65c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -675,6 +675,9 @@ prepare_loop() {
 prepare_ramdisk() {
 	local size=$1
 
+	# if brd is unused, remove and use for test
+	modprobe -r brd || return 0
+
 	echo -n "## preparing ramdisk device..."
 	modprobe brd rd_size=$((size * 1024)) || return
 

