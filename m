From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Mar 2014 09:23:49 +0000 (UTC)
Subject: master - test: Use correct path to /dev in lvchange-raid.sh.
Message-ID: <20140305092350.03E6D60CB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c9887467f3c33d5ea10503c74ad85c4b119d3df
Commit:        3c9887467f3c33d5ea10503c74ad85c4b119d3df
Parent:        08aedff1fc86d731f19993c259aaeee19cad7b8c
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Mar 5 10:21:49 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Mar 5 10:22:39 2014 +0100

test: Use correct path to /dev in lvchange-raid.sh.

---
 test/shell/lvchange-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 8fc91a3..0807fff 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -216,7 +216,7 @@ run_refresh_check() {
 
 	# Disable dev2 and do some I/O to make the kernel notice
 	aux disable_dev "$dev2"
-	dd if=/dev/urandom of=/dev/$sizelv bs=1k count=$size
+	dd if=/dev/urandom of=$DM_DEV_DIR/$sizelv bs=1k count=$size
 	sync
 
 	# Check for 'p'artial flag


