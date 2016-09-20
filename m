From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Sep 2016 20:48:40 +0000 (UTC)
Subject: master - tests: show some more device info
Message-ID: <20160920204840.D398B605CD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f6b0062727e9ef33610880444eaee857de1ab92
Commit:        9f6b0062727e9ef33610880444eaee857de1ab92
Parent:        994df22b608c40967c5327d5850af9a2a1b3eea3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 20 22:47:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 20 22:47:14 2016 +0200

tests: show some more device info

When passdown is not there, look for possible reason.
---
 test/shell/lvchange-thin.sh |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-thin.sh b/test/shell/lvchange-thin.sh
index f2b33b7..f943401 100644
--- a/test/shell/lvchange-thin.sh
+++ b/test/shell/lvchange-thin.sh
@@ -29,7 +29,12 @@ lvcreate -L10M -T $vg/pool
 # Check change operations on a thin-pool without any thin LV
 #
 # discards_ARG  (default is passdown)
-check grep_dmsetup status $vg-pool " discard_passdown"
+check grep_dmsetup status $vg-pool " discard_passdown" || {
+	# trace device layout
+	grep -r "" /sys/block/*
+	die "Device was expected to support passdown"
+}
+
 lvchange -vvvv --discards nopassdown $vg/pool
 check grep_dmsetup table $vg-pool " no_discard_passdown"
 check grep_dmsetup status $vg-pool " no_discard_passdown"


