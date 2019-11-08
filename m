From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Nov 2019 09:15:36 -0500
Subject: stable-2.02 - tests: add extra settle
Message-ID: <201911081415.xA8EFaPJ008392@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2f615e73de8aad74da77e69d57d012e5a1006389
Commit:        2f615e73de8aad74da77e69d57d012e5a1006389
Parent:        0e3e974bffa4e9842127451072eab1646ac39a1a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 8 15:09:17 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 8 15:12:51 2019 +0100

tests: add extra settle

To avoid removing, while 'add' might not have been processed yet.
(when emulating reboot in pvmove-restart)
---
 test/lib/aux.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 804200d..2241062 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1678,6 +1678,10 @@ wait_pvmove_lv_ready() {
 			retries=$((retries-1))
 		done
 	fi
+
+	# Adding settle here, to avoid remove, before processing of 'add' is finished
+	# (masking systemd-udevd issue)
+	udevadm settle --timeout=2 || true
 }
 
 # Holds device open with sleep which automatically expires after given timeout


