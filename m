From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:57 +0000 (UTC)
Subject: master - tests: use exclusive activation
Message-ID: <20140325102357.CF96B60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36d87eddcf280e9c394e10ac5860ed4d84eaf4a2
Commit:        36d87eddcf280e9c394e10ac5860ed4d84eaf4a2
Parent:        db1d4ba4ac267d32ef0c8c96d0e1785863d40f0a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 10:33:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:23:00 2014 +0100

tests: use exclusive activation

pvmove in cluster needs exlusive activation or cmirrord running.
---
 test/shell/pvmove-background.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-background.sh b/test/shell/pvmove-background.sh
index 0f657be..f38d723 100644
--- a/test/shell/pvmove-background.sh
+++ b/test/shell/pvmove-background.sh
@@ -15,7 +15,7 @@
 
 aux prepare_vg 3
 
-lvcreate -l1 -n $lv1 $vg "$dev1"
+lvcreate -aey -l1 -n $lv1 $vg "$dev1"
 
 lvs -o +devices | grep $dev1
 pvmove -i 1 -b "$dev1" "$dev2"


