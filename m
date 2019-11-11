From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:37 -0500
Subject: master - tests: add extra settle
Message-ID: <83496.119111116462900937@us-mta-146.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b05fd4d072d94bfead8c2d188ecf704fe57e2a8
Commit:        3b05fd4d072d94bfead8c2d188ecf704fe57e2a8
Parent:        ba313ac84a7bc27ce69d225dec1bfc80bcb20988
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 15:09:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

tests: add extra settle

To avoid removing, while 'add' might not have been processed yet.
(when emulating reboot in pvmove-restart)
---
 test/lib/aux.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 36e1c2b..6822d7e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1652,6 +1652,10 @@ wait_pvmove_lv_ready() {
 			retries=$((retries-1))
 		done
 	fi
+
+	# Adding settle here, to avoid remove, before processing of 'add' is finished
+	# (masking systemd-udevd issue)
+	udevadm settle --timeout=2 || true
 }
 
 # Holds device open with sleep which automatically expires after given timeout



