From: David Teigland <teigland@sourceware.org>
Date: Tue, 2 May 2017 17:49:22 -0400
Subject: master - man: references to lvm entities
Message-ID: <201705022149.v42LnMG7024531@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e15c7c5ff963e1a0287f25bca401bc3dbe515f76
Commit:        e15c7c5ff963e1a0287f25bca401bc3dbe515f76
Parent:        253bc5eb2e570fab788640e7256aeb52d1f51045
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 2 16:47:02 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 2 16:47:02 2017 -0500

man: references to lvm entities

Try to reference lvm(8) at the start of topical
man pages, and spell out acronyms early in the
text, descriptions of which can be found in lvm(8).
---
 man/lvmcache.7_main    |   11 ++++++-----
 man/lvmraid.7_main     |   18 ++++++++++--------
 man/lvmsystemid.7_main |    8 ++++----
 man/lvmthin.7_main     |   20 ++++++++++----------
 4 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 3ddb7cd..e573b58 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -4,9 +4,9 @@ lvmcache \(em LVM caching
 
 .SH DESCRIPTION
 
-The \fBcache\fP logical volume type uses a small and fast LV to improve
-the performance of a large and slow LV.  It does this by storing the
-frequently used blocks on the faster LV.
+An \fBlvm\fP(8) \fBcache\fP Logical Volume (LV) uses a small and
+fast LV to improve the performance of a large and slow LV.  It does this
+by storing the frequently used blocks on the faster LV.
 LVM refers to the small fast LV as a \fBcache pool LV\fP.  The large
 slow LV is called the \fBorigin LV\fP.  Due to requirements from dm-cache
 (the kernel driver), LVM further splits the cache pool LV into two
@@ -16,7 +16,8 @@ origin LV to increase speed.  The cache metadata LV holds the
 accounting information that specifies where data blocks are stored (e.g.
 on the origin LV or on the cache data LV).  Users should be familiar with
 these LVs if they wish to create the best and most robust cached
-logical volumes.  All of these associated LVs must be in the same VG.
+LVs.  All of these associated LVs must be in the same Volume
+Group (VG).
 
 .SH Cache Terms
 .nf
@@ -29,7 +30,7 @@ cache LV            CacheLV       OriginLV + CachePoolLV
 
 .SH Cache Usage
 
-The primary method for using a cache type logical volume:
+The primary method for using a cache type LV:
 
 
 .SS 0. create OriginLV
diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 47dc6ba..f0d28f5 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -5,14 +5,16 @@ lvmraid \(em LVM RAID
 
 .SH DESCRIPTION
 
-LVM RAID is a way to create logical volumes (LVs) that use multiple physical
-devices to improve performance or tolerate device failure.  How blocks of
-data in an LV are placed onto physical devices is determined by the RAID
-level.  RAID levels are commonly referred by a level specific number
-suffixed to the string 'raid', e.g. raid1, raid5 or raid6.
-Selecting a RAID level involves tradeoffs among physical device
-requirements, fault tolerance, and performance.  A description of the RAID
-levels can be found at
+\fBlvm\fP(8) RAID is a way to create a Logical Volume (LV) that uses
+multiple physical devices to improve performance or tolerate device
+failures.  In LVM, the physical devices are Physical Volumes (PVs) in a
+single Volume Group (VG).
+
+How LV data blocks are placed onto PVs is determined by the RAID level.
+RAID levels are commonly referred to as 'raid' followed by a number, e.g.
+raid1, raid5 or raid6.  Selecting a RAID level involves making tradeoffs
+among: physical device requirements, fault tolerance, and performance.  A
+description of the RAID levels can be found at
 .br
 www.snia.org/sites/default/files/SNIA_DDF_Technical_Position_v2.0.pdf
 
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index c1db4c9..8c57042 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -5,10 +5,10 @@ lvmsystemid \(em LVM system ID
 
 .SH DESCRIPTION
 
-The \fBlvm\fP(8) system ID restricts VG access to one host.  This is
-useful when a VG is placed on shared storage devices, or when local
-devices are visible to both host and guest operating systems.  In cases
-like these, a VG can be visible to multiple hosts at once, and some
+The \fBlvm\fP(8) system ID restricts Volume Group (VG) access to one host.
+This is useful when a VG is placed on shared storage devices, or when
+local devices are visible to both host and guest operating systems.  In
+cases like these, a VG can be visible to multiple hosts at once, and some
 mechanism is needed to protect it from being used by more than one host at
 a time.
 
diff --git a/man/lvmthin.7_main b/man/lvmthin.7_main
index c5efa9c..1ebeb65 100644
--- a/man/lvmthin.7_main
+++ b/man/lvmthin.7_main
@@ -5,17 +5,17 @@ lvmthin \(em LVM thin provisioning
 
 .SH DESCRIPTION
 
-Blocks in a standard logical volume are allocated when the LV is created,
-but blocks in a thin provisioned logical volume are allocated as they are
-written.  Because of this, a thin provisioned LV is given a virtual size,
-and can then be much larger than physically available storage.  The amount
-of physical storage provided for thin provisioned LVs can be increased
-later as the need arises.
-
-Blocks in a standard LV are allocated (during creation) from the VG, but
-blocks in a thin LV are allocated (during use) from a special "thin pool
-LV".  The thin pool LV contains blocks of physical storage, and blocks in
-thin LVs just reference blocks in the thin pool LV.
+Blocks in a standard \fBlvm\fP(8) Logical Volume (LV) are allocated when
+the LV is created, but blocks in a thin provisioned LV are allocated as
+they are written.  Because of this, a thin provisioned LV is given a
+virtual size, and can then be much larger than physically available
+storage.  The amount of physical storage provided for thin provisioned LVs
+can be increased later as the need arises.
+
+Blocks in a standard LV are allocated (during creation) from the Volume
+Group (VG), but blocks in a thin LV are allocated (during use) from a
+special "thin pool LV".  The thin pool LV contains blocks of physical
+storage, and blocks in thin LVs just reference blocks in the thin pool LV.
 
 A thin pool LV must be created before thin LVs can be created within it.
 A thin pool LV is created by combining two standard LVs: a large data LV


