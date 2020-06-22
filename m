From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Jun 2020 16:40:13 +0000 (GMT)
Subject: master - man: lvmcache info about cachedevice usage
Message-ID: <20200622164013.50AEF383E802@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bd9d81b29fb8ba490d87b3557861bf00047855d
Commit:        3bd9d81b29fb8ba490d87b3557861bf00047855d
Parent:        ae5634a8be3eedb556325a4b81540896fa6cac16
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 11 17:01:01 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 22 11:24:02 2020 -0500

man: lvmcache info about cachedevice usage

---
 man/lvmcache.7_main | 30 ++++++++++++++++++++++++++++--
 1 file changed, 28 insertions(+), 2 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 425904e4a..244ea1e48 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -34,8 +34,6 @@ LVM refers to this using the LV type \fBwritecache\fP.
 
 .SH USAGE
 
-Both kinds of caching use similar lvm commands:
-
 .B 1. Identify main LV that needs caching
 
 The main LV may already exist, and is located on larger, slower devices.
@@ -133,6 +131,22 @@ attached.
   main vg -wi------- linear /dev/slow_hhd
 .fi
 
+.SS Create a new LV with caching.
+
+A new LV can be created with caching attached at the time of creation
+using the following command:
+
+.nf
+$ lvcreate --type cache|writecache -n Name -L Size
+	--cachedevice /dev/fast_ssd vg /dev/slow_hhd
+.fi
+
+The main LV is created with the specified Name and Size from the slow_hhd.
+A hidden fast LV is created on the fast_ssd and is then attached to the
+new main LV.  If the fast_ssd is unused, the entire disk will be used as
+the cache unless the --cachesize option is used to specify a size for the
+fast LV.  The --cachedevice option can be repeated to use multiple disks
+for the fast LV.
 
 .SH OPTIONS
 
@@ -162,6 +176,18 @@ that cannot be used directly.  If a standard LV is passed with this
 option, lvm will first convert it to a cache pool by combining it with
 another LV to use for metadata.  This option can be used with dm-cache.
 
+.B --cachedevice
+.I PV
+.br
+
+This option can be used in place of --cachevol, in which case a cachevol
+LV will be created using the specified device.  This option can be
+repeated to create a cachevol using multiple devices, or a tag name can be
+specified in which case the cachevol will be created using any of the
+devices with the given tag.  If a named cache device is unused, the entire
+device will be used to create the cachevol.  To create a cachevol of a
+specific size from the cache devices, include the --cachesize option.
+
 \&
 
 .SS dm-cache block size


