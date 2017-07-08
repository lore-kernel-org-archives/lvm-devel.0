From: Eric Ren <zren@suse.com>
Date: Sun,  9 Jul 2017 01:15:51 +0800
Subject: [PATCH 3/3] man: specify slow device when creating origin LV
In-Reply-To: <20170708171551.19421-1-zren@suse.com>
References: <20170708171551.19421-1-zren@suse.com>
Message-ID: <20170708171551.19421-3-zren@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Also make the slow device name consistent everywhere.

Signed-off-by: Eric Ren <zren@suse.com>
---
 man/lvmcache.7_main | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

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
-- 
2.10.2


