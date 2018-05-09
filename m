From: David Teigland <teigland@sourceware.org>
Date: Wed, 9 May 2018 13:56:10 -0400
Subject: master - doc: add filter info to scanning
Message-ID: <201805091756.w49HuA5Q003487@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38f33251b182fdf4a1963dcd249d8d77ab6357ad
Commit:        38f33251b182fdf4a1963dcd249d8d77ab6357ad
Parent:        9a5bd01b0cf9526b3eb98c7521c281cbcee52732
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 9 11:14:05 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 9 12:54:38 2018 -0500

doc: add filter info to scanning

---
 doc/lvm-disk-reading.txt |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/doc/lvm-disk-reading.txt b/doc/lvm-disk-reading.txt
index 241a7ab..1255ae8 100644
--- a/doc/lvm-disk-reading.txt
+++ b/doc/lvm-disk-reading.txt
@@ -187,3 +187,45 @@ For each VG name:
   command-specific work
 
 
+
+Filter i/o
+----------
+
+Some filters must be applied before reading a device, and other filters
+must be applied after reading a device.  In all cases, the filters must be
+applied before lvm processes the device, i.e. before it looks for an lvm
+label.
+
+1. Some filters need to be applied prior to reading any devices
+   because the purpose of the filter is to avoid submitting any
+   io on the excluded devices.  The regex filter is the primary
+   example.  Other filters benefit from being applied prior to
+   reading devices because they can tell which devices to
+   exclude without doing io to the device.  An example of this
+   is the mpath filter.
+
+2. Some filters need to be applied after reading a device because
+   they are based on data/signatures seen on the device.
+   The partitioned filter is an example of this; lvm needs to
+   read a device to see if it has a partition table before it can
+   know whether to exclude the device from further processing.
+
+We apply filters from 1 before reading devices, and we apply filters from
+2 after populating bcache, but before processing the device (i.e. before
+checking for an lvm label, which is the first step in processing.)
+
+The current implementation of this makes filters return -EAGAIN if they
+want to read the device, but bcache data is not yet available.  This will
+happen when filtering runs prior to populating bcache.  In this case the
+device is flagged.  After bcache is populated, the filters are reapplied
+to the flagged devices.  The filters which need to look at device content
+are now able to get it from bcache.  Devices that do not pass filters at
+this point are excluded just like devices which were excluded earlier.
+
+(Some filters from 2 can be skipped by consulting udev for the information
+instead of reading the device.  This is not entirely reliable, so it is
+disabled by default with the config setting external_device_info_source.
+It may be worthwhile to change the filters to use the udev info as a hint,
+or only use udev info for filtering in reporting commands where
+inaccuracies are not a big problem.)
+


