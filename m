From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:28:13 +0000 (UTC)
Subject: master - tests: lets the test continue
Message-ID: <20140430082813.D2A0660DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4e559103d51e02c0d64d9cf88cee11d762feb65e
Commit:        4e559103d51e02c0d64d9cf88cee11d762feb65e
Parent:        94018279190d8f2d795a77482f3977f76687289b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 30 10:16:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:31 2014 +0200

tests: lets the test continue

unwanted start of dmeventd was caused by seg_monitor status.
---
 test/shell/listings.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 7d9c37e..79c9c89 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -73,7 +73,7 @@ lvcreate -T $vg/pool -I4 -i2 -l5 -V1P -n thin
 not dd if=/dev/zero of="$DM_DEV_DIR/$vg/inval" bs=4K
 invalid lvscan "$dev1"
 lvdisplay --maps
-not lvscan --all
+lvscan --all
 
 #COMM vgs with options from pvs still treats arguments as VGs (bz193543)
 vgs -o pv_name,vg_name $vg


