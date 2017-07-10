From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:59:53 -0400
Subject: master - man: specify slow device when creating origin LV
Message-ID: <201707101259.v6ACxrfs027898@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d71b738c171bfd93eabdca3c388a637a1aa55a6c
Commit:        d71b738c171bfd93eabdca3c388a637a1aa55a6c
Parent:        7617e08c0398bbfef66a710e377884c0793afa56
Author:        Eric Ren <zren@suse.com>
AuthorDate:    Sun Jul 9 01:15:51 2017 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:58:33 2017 +0200

man: specify slow device when creating origin LV

Also make the slow device name consistent everywhere.

Signed-off-by: Eric Ren <zren@suse.com>
---
 man/lvmcache.7_main |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 1f29185..6672ad3 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -41,7 +41,7 @@ Create an LV or identify an existing LV to be the origin LV.
 
 .I Example
 .br
-# lvcreate -n lvol0 -L 100G vg
+# lvcreate -n lvol0 -L 100G vg /dev/slow
 
 
 .SS 1. create CacheDataLV
@@ -199,7 +199,7 @@ pool sub-LVs redundant.
 .I Example
 .nf
 0. Create an origin LV we wish to cache
-# lvcreate -L 10G -n lv1 vg /dev/slow_devs
+# lvcreate -L 10G -n lv1 vg /dev/slow
 
 1. Create a 2-way RAID1 cache data LV
 # lvcreate --type raid1 -m 1 -L 1G -n cache1 vg \\


