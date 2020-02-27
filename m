From: David Teigland <teigland@sourceware.org>
Date: Thu, 27 Feb 2020 12:35:06 -0500
Subject: master - man: lvmcache raid1 references
Message-ID: <202002271735.01RHZ6B9019396@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c392ccaa470dbf1481cbf1c9e899ce9c59f2caea
Commit:        c392ccaa470dbf1481cbf1c9e899ce9c59f2caea
Parent:        9532bb577a82df454254ab65002f4be5bcc65060
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Feb 27 11:33:55 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 27 11:33:55 2020 -0600

man: lvmcache raid1 references

---
 man/lvmcache.7_main | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index d8e8dc7..425904e 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -417,13 +417,13 @@ compact, and stores dirty bits in a separate btree, which improves the
 speed of shutting down the cache.  With \fBauto\fP, lvm selects the best
 option provided by the current dm-cache kernel module.
 
-.SS mirrored cache device
+.SS RAID1 cache device
 
 \&
 
-The fast LV holding the cache can be created as a raid1 mirror so that it
-can tolerate a device failure.  (When using dm-cache with separate data
-and metadata LVs, each of the sub-LVs can use raid1.)
+RAID1 can be used to create the fast LV holding the cache so that it can
+tolerate a device failure.  (When using dm-cache with separate data
+and metadata LVs, each of the sub-LVs can use RAID1.)
 
 .nf
 $ lvcreate -n main -L Size vg /dev/slow



