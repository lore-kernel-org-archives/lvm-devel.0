From: David Teigland <teigland@sourceware.org>
Date: Thu, 23 May 2019 16:00:53 -0400
Subject: master - tests: pvscan-cache more attempts to fix
Message-ID: <201905232000.x4NK0rLp025596@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e055b89d2896ebe8b8067ab21f38d7ddbe2df9df
Commit:        e055b89d2896ebe8b8067ab21f38d7ddbe2df9df
Parent:        645dd276049e8dbab37b169b27cf6af29a8bd8e5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 23 14:55:57 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 23 14:55:57 2019 -0500

tests: pvscan-cache more attempts to fix

---
 test/shell/pvscan-cache.sh |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvscan-cache.sh b/test/shell/pvscan-cache.sh
index 8788594..20d3235 100644
--- a/test/shell/pvscan-cache.sh
+++ b/test/shell/pvscan-cache.sh
@@ -60,6 +60,7 @@ pvscan --cache -aay "$dev1"
 pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1/$lv1
+lvremove $vg1/$lv1
 
 # When MDA is ignored on PV, do not read any VG
 # metadata from such PV as it may contain old
@@ -75,7 +76,4 @@ aux enable_dev "$dev2"
 pvscan --cache
 check pv_field "$dev1" vg_name "$vg1"
 
-vgchange -an $vg1
-lvremove $vg1/$lv1
-
 vgremove -ff $vg1


