From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 13 Feb 2014 17:56:09 +0000 (UTC)
Subject: master - man: Add example/explanation section for cache LVs to lvm.8
Message-ID: <20140213175609.8323F610AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f4658b53d7f3292c802f33f5fd0cca807870049f
Commit:        f4658b53d7f3292c802f33f5fd0cca807870049f
Parent:        907641cd3de5c56c7840f22858c30b928429b1bf
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Feb 13 11:53:31 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Feb 13 11:53:31 2014 -0600

man: Add example/explanation section for cache LVs to lvm.8

I've added an "Advanced Logical Volume Types" section that I hope
to contain information on the logical volume types that may use
multiple steps and multiple commands to create.  Cache is the
first entry into this section.  I'd like to see thin and RAID in
here in the future.
---
 man/lvm.8.in |  153 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 153 insertions(+), 0 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 564e98b..e5cfb82 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -389,6 +389,159 @@ discretion over the layout.
 To view the way the allocation process currently works in any specific
 case, read the debug logging output, for example by adding \fB\-vvvv\fP to
 a command.
+
+.SH ADVANCED LOGICAL VOLUME TYPES
+Some logical volume types are simple to create and can be done with a
+single \fBlvcreate\fP(8) command.  The linear and striped logical
+volume types are an example of this.  Other logical volume types may
+require more than one command to create.  The cache and thinly provisioned
+types are examples of this.  This section is devoted to explaining the
+creation and monitoring of the more advanced types of logical volumes in
+LVM.  While the specifics of each command can be found in their respective
+man page, here you will find examples and best practices that may invoke
+multiple commands.
+.br
+.SS Cache Logical Volumes
+A cache logical volume is one that allows a small and fast block device to
+be used to improve the performance of larger and slower block devices.  It
+does this by storing the more frequently used blocks on the faster device.
+LVM refers to the small fast device as a "cache pool".  The large slow device
+is called the "origin".  Due to requirements from dm-cache (the kernel
+driver), LVM further splits the "cache pool" into two devices - the "cache pool
+metadata" and "cache pool data" devices.  The "cache pool data" device is where
+copies of data blocks are kept from the origin to increase speed.  The "cache
+pool metadata" device holds the accounting information that specifies where
+data blocks are stored (e.g. on the "origin" or in the "cache pool data" device).
+Users should be familiar with these three devices should they wish to create
+the best and most robust cached logical volumes.
+
+.SS Creating Cache Logical Volumes
+The steps to create a logical volume of cache type are as follows:
+.TP
+1)
+Create the cache pool's data device.  The size of this device directly
+correlates to the size of the cache and will ultimately be reported as
+the size of the cache pool.
+.TP
+2)
+Create the cache pool's metadata device.  The size of this device is
+loosely related to the size of the data device.  Generally, a user can
+size this 1000 times smaller than the cache pool data device with a
+minimum size of 8MiB.
+.TP
+3)
+Create the cache pool by combining the cache pool data and metadata
+logical volumes created in steps 1 & 2.  When performing this step,
+the user can specify behavioral characteristics of the cache pool if
+they wish.  If no new name is specified when combining, the name of the
+cache pool data device will become the name of the cachepool.  The sub-LVs
+are then renamed to <name>_cdata and <name>_cmeta.
+.TP
+4)
+Create a cached logical volume by linking the cache pool to an existing
+logical volume.  The user accessible cached LV keeps the name of the origin,
+while the actual origin device becomes a hidden LV with the name
+<origial name>_corig.  Users can perform this step while the device which
+is to be cached is in use.
+
+.P
+The above steps represent the best way to create a cached logical volume.
+They provide access to the most options and have the ability to create the
+most robust logical volumes.  The examples below will illustrate how these
+steps might be used in practice.
+
+.B Example 1:
+Creating a simple cache device named, "my_lv".
+.br
+
+.nf
+# Create a device we wish to cache (yours may already exist)
+Step-0> lvcreate -L 10G -n my_lv my_vg /dev/slow_dev
+
+# Create a cache pool data LV
+Step-1> lvcreate -L 1G -n cachepool my_vg /dev/fast_dev
+
+# Create a cache pool metadata LV (~1/1000th size of pool data)
+Step-2> lvcreate -L 8M -n meta my_vg /dev/fast_dev
+
+# Combine cache pool sub-LVs into a cache pool.
+Step-3> lvconvert --type cache_pool vg/cachepool --poolmetadata vg/meta
+
+# Combine the cache pool and origin to create a cached LV
+Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
+.fi
+
+Users who are concerned about the possibility of failures in their fast devices
+that could lead to data loss might consider making their cache pool sub-LVs
+redundant.  Example 2 illustrates how to do just that.  Note that only steps
+1 & 2 change slightly.
+
+.B Example 2:
+Creating a cache LV with a fault tolerant cache pool.
+
+.nf
+# Create a device we wish to cache (yours may already exist)
+Step-0> lvcreate -L 10G -n my_lv my_vg /dev/slow_dev
+
+# Create a 2-way RAID1 cache pool data LV
+Step-01> lvcreate --type raid1 -L 1G -n cachepool my_vg /dev/fast[12]
+
+# Create a 2-way RAID1 cache pool metadata LV
+Step-2> lvcreate --type raid1 -L 8M -n meta my_vg /dev/fast1 /dev/fast2
+
+# Combine cache pool sub-LVs into a cache pool.
+Step-3> lvconvert --type cache_pool vg/cachepool --poolmetadata vg/meta
+
+# Combine the cache pool and origin to create a cached LV
+Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
+.fi
+
+Some users wish to ensure that any data written will be stored both in the
+cache pool and on the origin.  The loss of the cache device in this case
+would not mean the loss of any data.  When combining the cache pool's sub-LVs
+to form the cachepool, behavioral characteristics of the cache can be
+specified - in this case, writethrough vs. writeback.  Note that only step
+3 is affected in this case.
+
+.B Example 3:
+Creating a simple cache device with "writethough" caching.
+
+.nf
+# Create a device we wish to cache (yours may already exist)
+Step-0> lvcreate -L 10G -n my_lv my_vg /dev/slow_dev
+
+# Create a cache pool data LV
+Step-1> lvcreate -L 1G -n cachepool my_vg /dev/fast_dev
+
+# Create a cache pool metadata LV
+Step-2> lvcreate -L 8M -n meta my_vg /dev/fast_dev
+
+# Combine cache pool sub-LVs into a cache pool and specify "writethough".
+Step-3> lvconvert --type cache_pool vg/cachepool \\
+	--poolmetadata vg/meta --cachemode writethrough -n cachepool
+
+# Combine the cache pool and origin to create a cached LV
+Step-4> lvconvert --type cache my_vg/my_lv --cachepool vg/cachepool
+.fi
+
+.SS Removing Cache Logical Volumes
+If users wish to remove all logical volumes associated with a cached
+logical volume, they must remove both top-level, user visible devices.
+The cache pool metadata and data logical volumes cannot be removed
+directly.  If only the cache pool is specfied for removal, any cached
+blocks not yet on the origin will be flush, the cache pool will be
+removed, and the now un-cached origin will remain.  If the user
+specifies a cached LV for removal, then the origin device is
+removed and only the cache pool will remain.  The cache pool can then be
+used to create another cache LV with a different origin if desired.
+
+When users intend to remove all logical volumes associated with a
+cached LV, it is generally better to start with the origin and then
+remove the cache pool.  If the operations are performed in the
+reverse order, the user will have to wait for the contents of the
+cache pool to be flushed before they remove the origin.  This
+could take some time.
+
 .SH DIAGNOSTICS
 All tools return a status code of zero on success or non-zero on failure.
 .SH FILES


