From: David Teigland <teigland@fedoraproject.org>
Date: Mon,  6 Oct 2014 19:05:13 +0000 (UTC)
Subject: master - man: lvmcache changes related to removal and splitting
Message-ID: <20141006190513.9660E60AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7c81769e72fe6ad4569c10de86090e75fe914ba
Commit:        b7c81769e72fe6ad4569c10de86090e75fe914ba
Parent:        902192abdc3bc8cf17c89b14db4496476e7fa73c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 6 14:04:09 2014 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 6 14:04:09 2014 -0500

man: lvmcache changes related to removal and splitting

---
 man/lvmcache.7.in |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/man/lvmcache.7.in b/man/lvmcache.7.in
index 6339b91..2603e1a 100644
--- a/man/lvmcache.7.in
+++ b/man/lvmcache.7.in
@@ -138,15 +138,30 @@ OriginLV is renamed OriginLV_corig and becomes hidden.
 
 .SH Cache Removal
 
+.SS Split a cache pool LV off of a cache LV
+
+\&
+
+A cache pool LV can be disconnected from a cache LV, leaving an
+unused cache pool LV, and an uncached origin LV.  This command
+writes back data from the cache pool to the origin LV when necessary.
+
+.B lvconvert --splitcache VG/CacheLV
+
 .SS Removing a cache pool LV without removing its linked origin LV
 
 \&
 
 This writes back data from the cache pool to the origin LV when necessary,
-then removes the cache pool LV, leaving the un-cached origin LV.
+then removes the cache pool LV, leaving the uncached origin LV.
 
 .B lvremove VG/CachePoolLV
 
+An alternative command that also disconnects the cache pool from the cache
+LV, and deletes the cache pool:
+
+.B lvconvert --uncache VG/CacheLV
+
 .I Example
 .nf
 # lvs vg
@@ -161,29 +176,15 @@ then removes the cache pool LV, leaving the un-cached origin LV.
   lvol0 vg   -wi-a----- 100.00g
 .fi
 
-.SS Removing an origin LV without removing its linked cache pool LV
+.SS Removing a cache LV: both origin LV and the cache pool LV
 
 \&
 
-This removes the origin LV, leaving the cache pool LV which can be linked
-to another origin LV.
+Removing a cache LV removes both the origin LV and the linked cache pool
+LV.
 
 .B lvremove VG/CacheLV
 
-.I Example
-.nf
-# lvs vg
-  LV     VG   Attr       LSize   Pool   Origin
-  cache0 vg   Cwi---C---  10.00g
-  lvol0  vg   Cwi-a-C--- 100.00g cache0 [lvol0_corig]
-
-# lvremove vg/lvol0
-
-# lvs vg
-  LV     VG   Attr       LSize  Pool Origin
-  cache0 vg   Cwi---C--- 10.00g
-.fi
-
 
 .SH Cache Topics
 


