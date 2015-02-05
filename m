From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:42:56 +0000 (UTC)
Subject: master - test: Avoid running 'dmsetup remove' with no devices.
Message-ID: <20150205134256.1831F6036E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6f9c4622378a312f0195ab968f8744b881d10b5
Commit:        c6f9c4622378a312f0195ab968f8744b881d10b5
Parent:        ad0267b2ad70258fe79c90ed7cdd31fa19c8bec1
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Sep 14 23:01:31 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:21 2015 +0100

test: Avoid running 'dmsetup remove' with no devices.

---
 test/shell/pvmove-restart.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index da6f3e5..86e2efa 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -41,7 +41,7 @@ wait
 # Simulate reboot - forcibly remove related devices
 dmsetup table
 dmsetup remove $vg-$lv1
-dmsetup ls --exec echo | grep $vg-pvmove0 | xargs dmsetup remove
+dmsetup ls --exec echo | grep $vg-pvmove0 | xargs -r dmsetup remove
 
 # Check we really have pvmove volume
 check lv_attr_bit type $vg/pvmove0 "p"


