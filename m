From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 May 2019 11:30:58 -0400
Subject: master - tests: fix error detection in lvconvert-raid-takeover.sh
Message-ID: <201905231530.x4NFUwtm005777@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6169c0a51b8098e4ffa15fb52cafccf7a73ab22c
Commit:        6169c0a51b8098e4ffa15fb52cafccf7a73ab22c
Parent:        2036608423117626eb1905b38e09c767983b2ef4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 23 10:29:52 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 23 10:29:52 2019 -0500

tests: fix error detection in lvconvert-raid-takeover.sh

---
 test/shell/lvconvert-raid-takeover.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index b57cbe9..6a4d554 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -26,7 +26,7 @@ aux prepare_vg 8
 # FIXME: lvconvert leaks  'error' devices
 detect_error_leak_()
 {
-	dmsetup table -S "name=~^$vg-" | not grep "error" || \
+	dmsetup table -S "name=~^$vg-" | awk '{print $3}'| not grep error || \
 		die "Device(s) with error target should not be here."
 }
 


