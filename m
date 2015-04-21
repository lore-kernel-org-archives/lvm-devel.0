From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Apr 2015 20:10:49 +0000 (UTC)
Subject: master - config: remove duplication of settings
Message-ID: <20150421201049.95A3D60B34@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47ed4cdc35d3ce6d0923ce05765f08fa7e85a6f9
Commit:        47ed4cdc35d3ce6d0923ce05765f08fa7e85a6f9
Parent:        9b86e8e8f4a3c429f8e5632103fbef6eb1f8dc7d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 15 16:15:30 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 21 14:55:03 2015 -0500

config: remove duplication of settings

The specific config settings have been removed
from the lvm.conf(5) man page, and replaced with
a description of how to use lvm dumpconfig to
view the settings.

The sample lvm.conf and lvmlocal.conf files are now generated:

example.conf.base  - initial ungenerated part of the file
example.conf.gen   - generated portion from dumpconfig
example.conf.in    - combination of .base and .gen files
example.conf       - result of configure processing .in file

lvmlocal.conf.base - initial ungenerated part of the file
lvmlocal.conf.gen  - generated portion from dumpconfig
lvmlocal.conf.in   - combination of .base and .gen files
lvmlocal.conf      - result of configure processing .in file

Do not edit the .in files, but edit config_settings.h
or the .base files, and then use 'make generate' to create
the new .in files.

- configure
  with options

- make
  creates tools/lvm

- make generate
  uses tools/lvm to create example.conf.in and lvmlocal.conf.in
  by combining .base files with dumpconfig output.

- configure
  with same options as above
  creates example.conf and lvmlocal.conf from .in files
---
 Makefile.in             |    5 +
 conf/Makefile.in        |    8 +
 conf/example.conf.base  |   12 +
 conf/example.conf.in    | 1384 -----------------------------------------------
 conf/lvmlocal.conf.base |   19 +
 conf/lvmlocal.conf.in   |   54 --
 make.tmpl.in            |    4 +
 man/lvm.conf.5.in       |  538 ++-----------------
 8 files changed, 90 insertions(+), 1934 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index a7bed8e..bce7bee 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -95,6 +95,11 @@ DISTCLEAN_TARGETS += cscope.out
 check check_system check_cluster check_local check_lvmetad unit: all
 	$(MAKE) -C test $(@)
 
+conf.generate: tools
+
+generate: conf.generate
+	$(MAKE) -C conf generate
+
 install_system_dirs:
 	$(INSTALL_DIR) $(DESTDIR)$(DEFAULT_SYS_DIR)
 	$(INSTALL_ROOT_DIR) $(DESTDIR)$(DEFAULT_ARCHIVE_DIR)
diff --git a/conf/Makefile.in b/conf/Makefile.in
index 2d48fb9..33f91c4 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -26,6 +26,14 @@ include $(top_builddir)/make.tmpl
 
 .PHONY: install_conf install_localconf install_profiles
 
+generate:
+	$(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments --ignorelocal > example.conf.gen
+	cat example.conf.base example.conf.gen > example.conf.in
+	rm example.conf.gen
+	$(top_builddir)/tools/lvm dumpconfig --type default --unconfigured --withfullcomments local > lvmlocal.conf.gen
+	cat lvmlocal.conf.base lvmlocal.conf.gen > lvmlocal.conf.in
+	rm lvmlocal.conf.gen
+
 install_conf: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "$(INSTALL_WDATA) -D $< $(confdir)/$(CONFDEST)"; \
diff --git a/conf/example.conf.base b/conf/example.conf.base
new file mode 100644
index 0000000..e4f4761
--- /dev/null
+++ b/conf/example.conf.base
@@ -0,0 +1,12 @@
+# This is an example configuration file for the LVM2 system.
+# It contains the default settings that would be used if there was no
+# @DEFAULT_SYS_DIR@/lvm.conf file.
+#
+# Refer to 'man lvm.conf' for further information including the file layout.
+#
+# To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
+# the environment variable LVM_SYSTEM_DIR before running the tools.
+#
+# N.B. Take care that each setting only appears once if uncommenting
+# example settings in this file.
+
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 1863a89..e69de29 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -1,1384 +0,0 @@
-# This is an example configuration file for the LVM2 system.
-# It contains the default settings that would be used if there was no
-# @DEFAULT_SYS_DIR@/lvm.conf file.
-#
-# Refer to 'man lvm.conf' for further information including the file layout.
-#
-# To put this file in a different directory and override @DEFAULT_SYS_DIR@ set
-# the environment variable LVM_SYSTEM_DIR before running the tools.
-#
-# N.B. Take care that each setting only appears once if uncommenting
-# example settings in this file.
-
-# This section allows you to set the way the configuration settings are handled.
-config {
-
-    # If enabled, any LVM2 configuration mismatch is reported.
-    # This implies checking that the configuration key is understood
-    # by LVM2 and that the value of the key is of a proper type.
-    # If disabled, any configuration mismatch is ignored and default
-    # value is used instead without any warning (a message about the
-    # configuration key not being found is issued in verbose mode only).
-    checks = 1
-
-    # If enabled, any configuration mismatch aborts the LVM2 process.
-    abort_on_errors = 0
-
-    # Directory where LVM looks for configuration profiles.
-    profile_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_PROFILE_SUBDIR@"
-}
-
-# This section allows you to configure which block devices should
-# be used by the LVM system.
-devices {
-
-    # Where do you want your volume groups to appear ?
-    dir = "/dev"
-
-    # An array of directories that contain the device nodes you wish
-    # to use with LVM2.
-    scan = [ "/dev" ]
-
-    # Select external device information source to use for further and more
-    # detailed device determination. Some information may already be available
-    # in the system and LVM2 can use this information to determine the exact
-    # type or use of the device it processes. Using existing external device
-    # information source can speed up device processing as LVM2 does not need
-    # to run its own native routines to acquire this information. For example,
-    # such information is used to drive LVM2 filtering like MD component
-    # detection, multipath component detection, partition detection and others.
-    # Possible options are:
-    # "none"        - No external device information source is used.
-    #
-    # "udev"        - Reuse existing udev database records. Applicable
-    #                 only if LVM is compiled with udev support.
-    #
-    external_device_info_source = "none"
-
-    # If set, the cache of block device nodes with all associated symlinks
-    # will be constructed out of the existing udev database content.
-    # This avoids using and opening any inapplicable non-block devices or
-    # subdirectories found in the device directory. This setting is applied
-    # to udev-managed device directory only, other directories will be scanned
-    # fully. LVM2 needs to be compiled with udev support for this setting to
-    # take effect. N.B. Any device node or symlink not managed by udev in
-    # udev directory will be ignored with this setting on.
-    obtain_device_list_from_udev = 1
-
-    # If several entries in the scanned directories correspond to the
-    # same block device and the tools need to display a name for device,
-    # all the pathnames are matched against each item in the following
-    # list of regular expressions in turn and the first match is used.
-
-    # By default no preferred names are defined.
-    # preferred_names = [ ]
-
-    # Try to avoid using undescriptive /dev/dm-N names, if present.
-    # preferred_names = [ "^/dev/mpath/", "^/dev/mapper/mpath", "^/dev/[hs]d" ]
-
-    # In case no prefererred name matches or if preferred_names are not
-    # defined@all, builtin rules are used to determine the preference.
-    #
-    # The first builtin rule checks path prefixes and it gives preference
-    # based on this ordering (where "dev" depends on devices/dev setting):
-    #   /dev/mapper > /dev/disk > /dev/dm-* > /dev/block
-    #
-    # If the ordering above cannot be applied, the path with fewer slashes
-    # gets preference then.
-    #
-    # If the number of slashes is the same, a symlink gets preference.
-    #
-    # Finally, if all the rules mentioned above are not applicable,
-    # lexicographical order is used over paths and the smallest one
-    # of all gets preference.
-
-
-    # A filter that tells LVM2 to only use a restricted set of devices.
-    # The filter consists of an array of regular expressions.  These
-    # expressions can be delimited by a character of your choice, and
-    # prefixed with either an 'a' (for accept) or 'r' (for reject).
-    # The first expression found to match a device name determines if
-    # the device will be accepted or rejected (ignored).  Devices that
-    # don't match any patterns are accepted.
-
-    # Be careful if there there are symbolic links or multiple filesystem 
-    # entries for the same device as each name is checked separately against
-    # the list of patterns.  The effect is that if the first pattern in the 
-    # list to match a name is an 'a' pattern for any of the names, the device
-    # is accepted; otherwise if the first pattern in the list to match a name
-    # is an 'r' pattern for any of the names it is rejected; otherwise it is
-    # accepted.
-
-    # Don't have more than one filter line active at once: only one gets used.
-
-    # Run vgscan after you change this parameter to ensure that
-    # the cache file gets regenerated (see below).
-    # If it doesn't do what you expect, check the output of 'vgscan -vvvv'.
-
-    # If lvmetad is used, then see "A note about device filtering while
-    # lvmetad is used" comment that is attached to global/use_lvmetad setting.
-
-    # By default we accept every block device:
-    # filter = [ "a/.*/" ]
-
-    # Exclude the cdrom drive
-    # filter = [ "r|/dev/cdrom|" ]
-
-    # When testing I like to work with just loopback devices:
-    # filter = [ "a/loop/", "r/.*/" ]
-
-    # Or maybe all loops and ide drives except hdc:
-    # filter =[ "a|loop|", "r|/dev/hdc|", "a|/dev/ide|", "r|.*|" ]
-
-    # Use anchors if you want to be really specific
-    # filter = [ "a|^/dev/hda8$|", "r/.*/" ]
-
-    # Since "filter" is often overridden from command line, it is not suitable
-    # for system-wide device filtering (udev rules, lvmetad). To hide devices
-    # from LVM-specific udev processing and/or from lvmetad, you need to set
-    # global_filter. The syntax is the same as for normal "filter"
-    # above. Devices that fail the global_filter are not even opened by LVM.
-
-    # global_filter = []
-
-    # The results of the filtering are cached on disk to avoid
-    # rescanning dud devices (which can take a very long time).
-    # By default this cache is stored in the @DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@ directory
-    # in a file called '.cache'.
-    # It is safe to delete the contents: the tools regenerate it.
-    # (The old setting 'cache' is still respected if neither of
-    # these new ones is present.)
-    # N.B. If obtain_device_list_from_udev is set to 1 the list of
-    # devices is instead obtained from udev and any existing .cache
-    # file is removed.
-    cache_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_CACHE_SUBDIR@"
-    cache_file_prefix = ""
-
-    # You can turn off writing this cache file by setting this to 0.
-    write_cache_state = 1
-
-    # Advanced settings.
-
-    # List of pairs of additional acceptable block device types found 
-    # in /proc/devices with maximum (non-zero) number of partitions.
-    # types = [ "fd", 16 ]
-
-    # If sysfs is mounted (2.6 kernels) restrict device scanning to 
-    # the block devices it believes are valid.
-    # 1 enables; 0 disables.
-    sysfs_scan = 1
-
-    # By default, LVM2 will ignore devices used as component paths
-    # of device-mapper multipath devices.
-    # 1 enables; 0 disables.
-    multipath_component_detection = 1
-
-    # By default, LVM2 will ignore devices used as components of
-    # software RAID (md) devices by looking for md superblocks.
-    # 1 enables; 0 disables.
-    md_component_detection = 1
-
-    # By default, LVM2 will not ignore devices used as components of
-    # firmware RAID devices. Set to 1 to enable this detection.
-    # N.B. LVM2 itself is not detecting firmware RAID - an
-    # external_device_info_source other than "none" must
-    # be used for this detection to execute.
-    # 1 enables; 0 disables
-    fw_raid_component_detection = 0
-
-    # By default, if a PV is placed directly upon an md device, LVM2
-    # will align its data blocks with the md device's stripe-width.
-    # 1 enables; 0 disables.
-    md_chunk_alignment = 1
-
-    # Default alignment of the start of a data area in MB.  If set to 0,
-    # a value of 64KB will be used.  Set to 1 for 1MiB, 2 for 2MiB, etc.
-    # default_data_alignment = @DEFAULT_DATA_ALIGNMENT@
-
-    # By default, the start of a PV's data area will be a multiple of
-    # the 'minimum_io_size' or 'optimal_io_size' exposed in sysfs.
-    # - minimum_io_size - the smallest request the device can perform
-    #   w/o incurring a read-modify-write penalty (e.g. MD's chunk size)
-    # - optimal_io_size - the device's preferred unit of receiving I/O
-    #   (e.g. MD's stripe width)
-    # minimum_io_size is used if optimal_io_size is undefined (0).
-    # If md_chunk_alignment is enabled, that detects the optimal_io_size.
-    # This setting takes precedence over md_chunk_alignment.
-    # 1 enables; 0 disables.
-    data_alignment_detection = 1
-
-    # Alignment (in KB) of start of data area when creating a new PV.
-    # md_chunk_alignment and data_alignment_detection are disabled if set.
-    # Set to 0 for the default alignment (see: data_alignment_default)
-    # or page size, if larger.
-    data_alignment = 0
-
-    # By default, the start of the PV's aligned data area will be shifted by
-    # the 'alignment_offset' exposed in sysfs.  This offset is often 0 but
-    # may be non-zero; e.g.: certain 4KB sector drives that compensate for
-    # windows partitioning will have an alignment_offset of 3584 bytes
-    # (sector 7 is the lowest aligned logical block, the 4KB sectors start
-    # at LBA -1, and consequently sector 63 is aligned on a 4KB boundary).
-    # But note that pvcreate --dataalignmentoffset will skip this detection.
-    # 1 enables; 0 disables.
-    data_alignment_offset_detection = 1
-
-    # If, while scanning the system for PVs, LVM2 encounters a device-mapper
-    # device that has its I/O suspended, it waits for it to become accessible.
-    # Set this to 1 to skip such devices.  This should only be needed
-    # in recovery situations.
-    ignore_suspended_devices = 0
-
-    # ignore_lvm_mirrors:  Introduced in version 2.02.104
-    # This setting determines whether logical volumes of "mirror" segment
-    # type are scanned for LVM labels.  This affects the ability of
-    # mirrors to be used as physical volumes.  If 'ignore_lvm_mirrors'
-    # is set to '1', it becomes impossible to create volume groups on top
-    # of mirror logical volumes - i.e. to stack volume groups on mirrors.
-    #
-    # Allowing mirror logical volumes to be scanned (setting the value to '0')
-    # can potentially cause LVM processes and I/O to the mirror to become
-    # blocked.  This is due to the way that the "mirror" segment type handles
-    # failures.  In order for the hang to manifest itself, an LVM command must
-    # be run just after a failure and before the automatic LVM repair process
-    # takes place OR there must be failures in multiple mirrors in the same
-    # volume group at the same time with write failures occurring moments
-    # before a scan of the mirror's labels.
-    #
-    # Note that these scanning limitations do not apply to the LVM RAID
-    # types, like "raid1".  The RAID segment types handle failures in a
-    # different way and are not subject to possible process or I/O blocking.
-    #
-    # It is encouraged that users set 'ignore_lvm_mirrors' to 1 if they
-    # are using the "mirror" segment type.  Users that require volume group
-    # stacking on mirrored logical volumes should consider using the "raid1"
-    # segment type.  The "raid1" segment type is not available for
-    # active/active clustered volume groups.
-    #
-    # Set to 1 to disallow stacking and thereby avoid a possible deadlock.
-    ignore_lvm_mirrors = 1
-
-    # During each LVM operation errors received from each device are counted.
-    # If the counter of a particular device exceeds the limit set here, no
-    # further I/O is sent to that device for the remainder of the respective
-    # operation. Setting the parameter to 0 disables the counters altogether.
-    disable_after_error_count = 0
-
-    # Allow use of pvcreate --uuid without requiring --restorefile.
-    require_restorefile_with_uuid = 1
-
-    # Minimum size (in KB) of block devices which can be used as PVs.
-    # In a clustered environment all nodes must use the same value.
-    # Any value smaller than 512KB is ignored.
-
-    # Ignore devices smaller than 2MB such as floppy drives.
-    pv_min_size = 2048
-
-    # The original built-in setting was 512 up to and including version 2.02.84.
-    # pv_min_size = 512
-
-    # Issue discards to a logical volumes's underlying physical volume(s) when
-    # the logical volume is no longer using the physical volumes' space (e.g.
-    # lvremove, lvreduce, etc).  Discards inform the storage that a region is
-    # no longer in use.  Storage that supports discards advertise the protocol
-    # specific way discards should be issued by the kernel (TRIM, UNMAP, or
-    # WRITE SAME with UNMAP bit set).  Not all storage will support or benefit
-    # from discards but SSDs and thinly provisioned LUNs generally do.  If set
-    # to 1, discards will only be issued if both the storage and kernel provide
-    # support.
-    # 1 enables; 0 disables.
-    issue_discards = 0
-}
-
-# This section allows you to configure the way in which LVM selects
-# free space for its Logical Volumes.
-allocation {
-
-    # When searching for free space to extend an LV, the "cling"
-    # allocation policy will choose space on the same PVs as the last
-    # segment of the existing LV.  If there is insufficient space and a
-    # list of tags is defined here, it will check whether any of them are
-    # attached to the PVs concerned and then seek to match those PV tags
-    # between existing extents and new extents.
-    # Use the special tag "@*" as a wildcard to match any PV tag.
- 
-    # Example: LVs are mirrored between two sites within a single VG.
-    # PVs are tagged with either @site1 or @site2 to indicate where
-    # they are situated.
-
-    # cling_tag_list = [ "@site1", "@site2" ]
-    # cling_tag_list = [ "@*" ]
-
-    # Changes made in version 2.02.85 extended the reach of the 'cling'
-    # policies to detect more situations where data can be grouped
-    # onto the same disks.  Set this to 0 to revert to the previous
-    # algorithm.
-    maximise_cling = 1
-
-    # Whether to use blkid library instead of native LVM2 code to detect
-    # any existing signatures while creating new Physical Volumes and
-    # Logical Volumes. LVM2 needs to be compiled with blkid wiping support
-    # for this setting to take effect.
-    #
-    # LVM2 native detection code is currently able to recognize these signatures:
-    #   - MD device signature
-    #   - swap signature
-    #   - LUKS signature
-    # To see the list of signatures recognized by blkid, check the output
-    # of 'blkid -k' command. The blkid can recognize more signatures than
-    # LVM2 native detection code, but due to this higher number of signatures
-    # to be recognized, it can take more time to complete the signature scan.
-    use_blkid_wiping = 1
-
-    # Set to 1 to detect any signatures found on newly-created Logical Volume
-    # whenever zeroing of the LV is done (zeroing is controlled by -Z/--zero
-    # option and if not specified, zeroing is used by default if possible).
-    #
-    # While zeroing simply overwrites first 4 KiB of the LV with zeroes without
-    # doing any signature detection, signature wiping goes beyond that and it
-    # can detect exact type and position of signature within the whole LV.
-    # As such, it provides cleaner LV for use after creation as all known
-    # signatures are wiped so that the LV is not claimed by other tools
-    # incorrectly by the existence of old signature from any previous use.
-    # The number of signatures that LVM can detect depends on detection
-    # code that is selected - see also use_blkid_wiping option.
-    #
-    # Wiping of each detected signature must be confirmed.
-    #
-    # The default is to wipe signatures when zeroing. The command line
-    # option -W/--wipesignatures takes precedence over this setting.
-    #
-    # Without this option set, signatures on newly-created Logical Volumes
-    # are never detected and wiped and you always need to use
-    # -W/--wipesignatures y option directly to enable this feature
-    # no matter whether zeroing is used or not.
-    wipe_signatures_when_zeroing_new_lvs = 1
-
-    # Set to 1 to guarantee that mirror logs will always be placed on 
-    # different PVs from the mirror images.  This was the default
-    # until version 2.02.85.
-    mirror_logs_require_separate_pvs = 0
-
-    # Set to 1 to guarantee that cache_pool metadata will always be
-    # placed on  different PVs from the cache_pool data.
-    cache_pool_metadata_require_separate_pvs = 0
-
-    # Specify the minimal chunk size (in kiB) for cache pool volumes.
-    # Using a chunk_size that is too large can result in wasteful use of
-    # the cache, where small reads and writes can cause large sections of
-    # an LV to be mapped into the cache.  However, choosing a chunk_size
-    # that is too small can result in more overhead trying to manage the
-    # numerous chunks that become mapped into the cache.  The former is
-    # more of a problem than the latter in most cases, so we default to
-    # a value that is on the smaller end of the spectrum.  Supported values
-    # range from 32(kiB) to 1048576 in multiples of 32.
-    # cache_pool_chunk_size = 64
-
-    # Specify the default cache mode used for new cache pools.
-    # Possible options are:
-    # "writethrough"    - Data blocks are immediately written from
-    #                     the cache to disk.
-    # "writeback"       - Data blocks are written from the cache
-    #                     back to disk after some delay to improve
-    #                     performance.
-    # cache_pool_cachemode = "writethrough"
-
-    # Set to 1 to guarantee that thin pool metadata will always
-    # be placed on different PVs from the pool data.
-    thin_pool_metadata_require_separate_pvs = 0
-
-    # Specify chunk size calculation policy for thin pool volumes.
-    # Possible options are:
-    # "generic"        - if thin_pool_chunk_size is defined, use it.
-    #                    Otherwise, calculate the chunk size based on
-    #                    estimation and device hints exposed in sysfs:
-    #                    the minimum_io_size. The chunk size is always
-    #                    at least 64KiB.
-    #
-    # "performance"    - if thin_pool_chunk_size is defined, use it.
-    # 			 Otherwise, calculate the chunk size for
-    # 			 performance based on device hints exposed in
-    # 			 sysfs: the optimal_io_size. The chunk size is
-    # 			 always at least 512KiB.
-    # thin_pool_chunk_size_policy = "generic"
-
-    # Specify the minimal chunk size (in KB) for thin pool volumes.
-    # Use of the larger chunk size may improve performance for plain
-    # thin volumes, however using them for snapshot volumes is less efficient,
-    # as it consumes more space and takes extra time for copying.
-    # When unset, lvm tries to estimate chunk size starting from 64KB
-    # Supported values are in range from 64 to 1048576.
-    # thin_pool_chunk_size = 64
-
-    # Specify discards behaviour of the thin pool volume.
-    # Select one of  "ignore", "nopassdown", "passdown"
-    # thin_pool_discards = "passdown"
-
-    # Set to 0, to disable zeroing of thin pool data chunks before their
-    # first use.
-    # N.B. zeroing larger thin pool chunk size degrades performance.
-    # thin_pool_zero = 1
-
-    # Default physical extent size to use for newly created VGs (in KB).
-    # physical_extent_size = 4096
-}
-
-# This section that allows you to configure the nature of the
-# information that LVM2 reports.
-log {
-
-    # Controls the messages sent to stdout or stderr.
-    # There are three levels of verbosity, 3 being the most verbose.
-    verbose = 0
-
-    # Set to 1 to suppress all non-essential messages from stdout.
-    # This has the same effect as -qq.
-    # When this is set, the following commands still produce output:
-    # dumpconfig, lvdisplay, lvmdiskscan, lvs, pvck, pvdisplay, 
-    # pvs, version, vgcfgrestore -l, vgdisplay, vgs.
-    # Non-essential messages are shifted from log level 4 to log level 5
-    # for syslog and lvm2_log_fn purposes.
-    # Any 'yes' or 'no' questions not overridden by other arguments
-    # are suppressed and default to 'no'.
-    silent = 0
-
-    # Should we send log messages through syslog?
-    # 1 is yes; 0 is no.
-    syslog = 1
-
-    # Should we log error and debug messages to a file?
-    # By default there is no log file.
-    #file = "/var/log/lvm2.log"
-
-    # Should we overwrite the log file each time the program is run?
-    # By default we append.
-    overwrite = 0
-
-    # What level of log messages should we send to the log file and/or syslog?
-    # There are 6 syslog-like log levels currently in use - 2 to 7 inclusive.
-    # 7 is the most verbose (LOG_DEBUG).
-    level = 0
-
-    # Format of output messages
-    # Whether or not (1 or 0) to indent messages according to their severity
-    indent = 1
-
-    # Whether or not (1 or 0) to display the command name on each line output
-    command_names = 0
-
-    # A prefix to use before the message text (but after the command name,
-    # if selected).  Default is two spaces, so you can see/grep the severity
-    # of each message.
-    prefix = "  "
-
-    # To make the messages look similar to the original LVM tools use:
-    #   indent = 0
-    #   command_names = 1
-    #   prefix = " -- "
-
-    # Set this if you want log messages during activation.
-    # Don't use this in low memory situations (can deadlock).
-    # activation = 0
-
-    # Some debugging messages are assigned to a class and only appear
-    # in debug output if the class is listed here.
-    # Classes currently available:
-    #   memory, devices, activation, allocation, lvmetad, metadata, cache,
-    #   locking
-    # Use "all" to see everything.
-    debug_classes = [ "memory", "devices", "activation", "allocation",
-		      "lvmetad", "metadata", "cache", "locking" ]
-}
-
-# Configuration of metadata backups and archiving.  In LVM2 when we
-# talk about a 'backup' we mean making a copy of the metadata for the
-# *current* system.  The 'archive' contains old metadata configurations.
-# Backups are stored in a human readable text format.
-backup {
-
-    # Should we maintain a backup of the current metadata configuration ?
-    # Use 1 for Yes; 0 for No.
-    # Think very hard before turning this off!
-    backup = 1
-
-    # Where shall we keep it ?
-    # Remember to back up this directory regularly!
-    backup_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_BACKUP_SUBDIR@"
-
-    # Should we maintain an archive of old metadata configurations.
-    # Use 1 for Yes; 0 for No.
-    # On by default.  Think very hard before turning this off.
-    archive = 1
-
-    # Where should archived files go ?
-    # Remember to back up this directory regularly!
-    archive_dir = "@DEFAULT_SYS_DIR@/@DEFAULT_ARCHIVE_SUBDIR@"
-
-    # What is the minimum number of archive files you wish to keep ?
-    retain_min = 10
-
-    # What is the minimum time you wish to keep an archive file for ?
-    retain_days = 30
-}
-
-# Settings for the running LVM2 in shell (readline) mode.
-shell {
-
-    # Number of lines of history to store in ~/.lvm_history
-    history_size = 100
-}
-
-
-# Miscellaneous global LVM2 settings
-global {
-    # The file creation mask for any files and directories created.
-    # Interpreted as octal if the first digit is zero.
-    umask = 077
-
-    # Allow other users to read the files
-    #umask = 022
-
-    # Enabling test mode means that no changes to the on disk metadata
-    # will be made.  Equivalent to having the -t option on every
-    # command.  Defaults to off.
-    test = 0
-
-    # Default value for --units argument
-    units = "h"
-
-    # Since version 2.02.54, the tools distinguish between powers of
-    # 1024 bytes (e.g. KiB, MiB, GiB) and powers of 1000 bytes (e.g.
-    # KB, MB, GB).
-    # If you have scripts that depend on the old behaviour, set this to 0
-    # temporarily until you update them.
-    si_unit_consistency = 1
-
-    # Whether or not to display unit suffix for sizes. This setting has
-    # no effect if the units are in human-readable form (global/units="h")
-    # in which case the suffix is always displayed.
-    suffix = 1
-
-    # Whether or not to communicate with the kernel device-mapper.
-    # Set to 0 if you want to use the tools to manipulate LVM metadata 
-    # without activating any logical volumes.
-    # If the device-mapper kernel driver is not present in your kernel
-    # setting this to 0 should suppress the error messages.
-    activation = 1
-
-    # If we can't communicate with device-mapper, should we try running 
-    # the LVM1 tools?
-    # This option only applies to 2.4 kernels and is provided to help you
-    # switch between device-mapper kernels and LVM1 kernels.
-    # The LVM1 tools need to be installed with .lvm1 suffices
-    # e.g. vgscan.lvm1 and they will stop working after you start using
-    # the new lvm2 on-disk metadata format.
-    # The default value is set when the tools are built.
-    # fallback_to_lvm1 = 0
-
-    # The default metadata format that commands should use - "lvm1" or "lvm2".
-    # The command line override is -M1 or -M2.
-    # Defaults to "lvm2".
-    # format = "lvm2"
-
-    # Location of /etc system configuration directory.
-    etc = "@CONFDIR@"
-
-    # Location of proc filesystem
-    proc = "/proc"
-
-    # Type of locking to use. Defaults to local file-based locking (1).
-    # Turn locking off by setting to 0 (dangerous: risks metadata corruption
-    # if LVM2 commands get run concurrently).
-    # Type 2 uses the external shared library locking_library.
-    # Type 3 uses built-in clustered locking.
-    # Type 4 uses read-only locking which forbids any operations that might 
-    # change metadata.
-    # Type 5 offers dummy locking for tools that do not need any locks.
-    # You should not need to set this directly: the tools will select when
-    # to use it instead of the configured locking_type.  Do not use lvmetad or
-    # the kernel device-mapper driver with this locking type.
-    # It is used by the --readonly option that offers read-only access to
-    # Volume Group metadata that cannot be locked safely because it belongs to
-    # an inaccessible domain and might be in use, for example a virtual machine
-    # image or a disk that is shared by a clustered machine.  
-    #
-    # N.B. Don't use lvmetad with locking type 3 as lvmetad is not yet
-    # supported in clustered environment. If use_lvmetad=1 and locking_type=3
-    # is set at the same time, LVM always issues a warning message about this
-    # and then it automatically disables lvmetad use.
-    locking_type = 1
-
-    # Set to 0 to fail when a lock request cannot be satisfied immediately.
-    wait_for_locks = 1
-
-    # If using external locking (type 2) and initialisation fails,
-    # with this set to 1 an attempt will be made to use the built-in
-    # clustered locking.
-    # If you are using a customised locking_library you should set this to 0.
-    fallback_to_clustered_locking = 1
-
-    # If an attempt to initialise type 2 or type 3 locking failed, perhaps
-    # because cluster components such as clvmd are not running, with this set
-    # to 1 an attempt will be made to use local file-based locking (type 1).
-    # If this succeeds, only commands against local volume groups will proceed.
-    # Volume Groups marked as clustered will be ignored.
-    fallback_to_local_locking = 1
-
-    # Local non-LV directory that holds file-based locks while commands are
-    # in progress.  A directory like /tmp that may get wiped on reboot is OK.
-    locking_dir = "@DEFAULT_LOCK_DIR@"
-
-    # Whenever there are competing read-only and read-write access requests for
-    # a volume group's metadata, instead of always granting the read-only
-    # requests immediately, delay them to allow the read-write requests to be
-    # serviced.  Without this setting, write access may be stalled by a high
-    # volume of read-only requests.
-    # NB. This option only affects locking_type = 1 viz. local file-based
-    # locking.
-    prioritise_write_locks = 1
-
-    # Other entries can go here to allow you to load shared libraries
-    # e.g. if support for LVM1 metadata was compiled as a shared library use
-    #   format_libraries = "liblvm2format1.so" 
-    # Full pathnames can be given.
-
-    # Search this directory first for shared libraries.
-    #   library_dir = "/lib"
-
-    # The external locking library to load if locking_type is set to 2.
-    #   locking_library = "liblvm2clusterlock.so"
-
-    # Treat any internal errors as fatal errors, aborting the process that
-    # encountered the internal error. Please only enable for debugging.
-    abort_on_internal_errors = 0
-
-    # Check whether CRC is matching when parsed VG is used multiple times.
-    # This is useful to catch unexpected internal cached volume group
-    # structure modification. Please only enable for debugging.
-    detect_internal_vg_cache_corruption = 0
-
-    # If set to 1, no operations that change on-disk metadata will be permitted.
-    # Additionally, read-only commands that encounter metadata in need of repair
-    # will still be allowed to proceed exactly as if the repair had been 
-    # performed (except for the unchanged vg_seqno).
-    # Inappropriate use could mess up your system, so seek advice first!
-    metadata_read_only = 0
-
-    # 'mirror_segtype_default' defines which segtype will be used when the
-    # shorthand '-m' option is used for mirroring.  The possible options are:
-    #
-    # "mirror" - The original RAID1 implementation provided by LVM2/DM.  It is
-    # 	         characterized by a flexible log solution (core, disk, mirrored)
-    #		 and by the necessity to block I/O while reconfiguring in the
-    #		 event of a failure.
-    #
-    #		 There is an inherent race in the dmeventd failure handling
-    #		 logic with snapshots of devices using this type of RAID1 that
-    #		 in the worst case could cause a deadlock.
-    #		   Ref: https://bugzilla.redhat.com/show_bug.cgi?id=817130#c10
-    #
-    # "raid1"  - This implementation leverages MD's RAID1 personality through
-    # 	       	 device-mapper.  It is characterized by a lack of log options.
-    #		 (A log is always allocated for every device and they are placed
-    #		 on the same device as the image - no separate devices are
-    #		 required.)  This mirror implementation does not require I/O
-    #		 to be blocked in the kernel in the event of a failure.
-    #		 This mirror implementation is not cluster-aware and cannot be
-    #		 used in a shared (active/active) fashion in a cluster.
-    #
-    # Specify the '--type <mirror|raid1>' option to override this default
-    # setting.
-    mirror_segtype_default = "@DEFAULT_MIRROR_SEGTYPE@"
-
-    # 'raid10_segtype_default' determines the segment types used by default
-    # when the '--stripes/-i' and '--mirrors/-m' arguments are both specified
-    # during the creation of a logical volume.
-    # Possible settings include:
-    #
-    # "raid10" - This implementation leverages MD's RAID10 personality through
-    #            device-mapper.
-    #
-    # "mirror" - LVM will layer the 'mirror' and 'stripe' segment types.  It
-    #            will do this by creating a mirror on top of striped sub-LVs;
-    #            effectively creating a RAID 0+1 array.  This is suboptimal
-    #            in terms of providing redundancy and performance. Changing to
-    #            this setting is not advised.
-    # Specify the '--type <raid10|mirror>' option to override this default
-    # setting.
-    raid10_segtype_default = "@DEFAULT_RAID10_SEGTYPE@"
-
-    # 'sparse_segtype_default' defines which segtype will be used when the
-    # shorthand '-V and -L' option is used for sparse volume creation.
-    #
-    # "snapshot" - The original snapshot implementation provided by LVM2/DM.
-    #		   It is using old snashot that mixes data and metadata within
-    #		   a single COW storage volume and has poor performs when
-    #		   the size of stored data passes hundereds of MB.
-    #
-    # "thin"     - Newer implementation leverages thin provisioning target.
-    #		   It has bigger minimal chunk size (64KiB) and uses separate volume
-    #		   for metadata. It has better performance especially in case of
-    #		   bigger data uses. This device type has also full snapshot support.
-    #
-    # Specify the '--type <snapshot|thin>' option to override this default
-    # setting.
-    sparse_segtype_default = "@DEFAULT_SPARSE_SEGTYPE@"
-
-
-    # The default format for displaying LV names in lvdisplay was changed 
-    # in version 2.02.89 to show the LV name and path separately.
-    # Previously this was always shown as /dev/vgname/lvname even when that
-    # was never a valid path in the /dev filesystem.
-    # Set to 1 to reinstate the previous format.
-    #
-    # lvdisplay_shows_full_device_path = 0
-
-    # Whether to use (trust) a running instance of lvmetad. If this is set to
-    # 0, all commands fall back to the usual scanning mechanisms. When set to 1
-    # *and* when lvmetad is running (automatically instantiated by making use of
-    # systemd's socket-based service activation or run as an initscripts service
-    # or run manually), the volume group metadata and PV state flags are obtained
-    # from the lvmetad instance and no scanning is done by the individual
-    # commands. In a setup with lvmetad, lvmetad udev rules *must* be set up for
-    # LVM to work correctly. Without proper udev rules, all changes in block
-    # device configuration will be *ignored* until a manual 'pvscan --cache'
-    # is performed. These rules are installed by default.
-    #
-    # If lvmetad has been running while use_lvmetad was 0, it MUST be stopped
-    # before changing use_lvmetad to 1 and started again afterwards.
-    #
-    # If using lvmetad, volume activation is also switched to automatic
-    # event-based mode. In this mode, the volumes are activated based on
-    # incoming udev events that automatically inform lvmetad about new PVs that
-    # appear in the system. Once a VG is complete (all the PVs are present), it
-    # is auto-activated. The activation/auto_activation_volume_list setting
-    # controls which volumes are auto-activated (all by default).
-
-    # A note about device filtering while lvmetad is used:
-
-    # When lvmetad is updated (either automatically based on udev events or
-    # directly by a pvscan --cache <device> call), devices/filter is ignored and
-    # all devices are scanned by default -- lvmetad always keeps unfiltered
-    # information which is then provided to LVM commands and then each LVM
-    # command does the filtering based on devices/filter setting itself.  This
-    # does not apply to non-regexp filters though: component filters such as
-    # multipath and MD are checked at pvscan --cache time.
-
-    # In order to completely prevent LVM from scanning a device, even when using
-    # lvmetad, devices/global_filter must be used.
-
-    # N.B. Don't use lvmetad with locking type 3 as lvmetad is not yet
-    # supported in clustered environment. If use_lvmetad=1 and locking_type=3
-    # is set at the same time, LVM always issues a warning message about this
-    # and then it automatically disables use_lvmetad.
-
-    use_lvmetad = 0
-
-    # Full path of the utility called to check that a thin metadata device
-    # is in a state that allows it to be used.
-    # Each time a thin pool needs to be activated or after it is deactivated
-    # this utility is executed. The activation will only proceed if the utility
-    # has an exit status of 0.
-    # Set to "" to skip this check.  (Not recommended.)
-    # The thin tools are available as part of the device-mapper-persistent-data
-    # package from https://github.com/jthornber/thin-provisioning-tools.
-    #
-    # thin_check_executable = "@THIN_CHECK_CMD@"
-
-    # Array of string options passed with thin_check command. By default,
-    # option "-q" is for quiet output.
-    # With thin_check version 2.1 or newer you can add "--ignore-non-fatal-errors"
-    # to let it pass through ignorable errors and fix them later.
-    # With thin_check version 3.2 or newer you should add
-    # "--clear-needs-check-flag".
-    #
-    # thin_check_options = [ "-q", "--clear-needs-check-flag" ]
-
-    # Full path of the utility called to repair a thin metadata device
-    # is in a state that allows it to be used.
-    # Each time a thin pool needs repair this utility is executed.
-    # See thin_check_executable how to obtain binaries.
-    #
-    # thin_repair_executable = "@THIN_REPAIR_CMD@"
-
-    # Array of extra string options passed with thin_repair command.
-    # thin_repair_options = [ "" ]
-
-    # Full path of the utility called to dump thin metadata content.
-    # See thin_check_executable how to obtain binaries.
-    #
-    # thin_dump_executable = "@THIN_DUMP_CMD@"
-
-    # If set, given features are not used by thin driver.
-    # This can be helpful not just for testing, but i.e. allows to avoid
-    # using problematic implementation of some thin feature.
-    # Features:
-    #   block_size
-    #   discards
-    #   discards_non_power_2
-    #   external_origin
-    #   metadata_resize
-    #   external_origin_extend
-    #   error_if_no_space
-    #
-    # thin_disabled_features = [ "discards", "block_size" ]
-
-    # Full path of the utility called to check that a cache metadata device
-    # is in a state that allows it to be used.
-    # Each time a cached LV needs to be used or after it is deactivated
-    # this utility is executed. The activation will only proceed if the utility
-    # has an exit status of 0.
-    # Set to "" to skip this check.  (Not recommended.)
-    # The cache tools are available as part of the device-mapper-persistent-data
-    # package from https://github.com/jthornber/thin-provisioning-tools.
-    #
-    # cache_check_executable = "@CACHE_CHECK_CMD@"
-
-    # Array of string options passed with cache_check command. By default,
-    # option "-q" is for quiet output.
-    #
-    # cache_check_options = [ "-q" ]
-
-    # Full path of the utility called to repair a cache metadata device.
-    # Each time a cache metadata needs repair this utility is executed.
-    # See cache_check_executable how to obtain binaries.
-    #
-    # cache_repair_executable = "@CACHE_REPAIR_CMD@"
-
-    # Array of extra string options passed with cache_repair command.
-    # cache_repair_options = [ "" ]
-
-    # Full path of the utility called to dump cache metadata content.
-    # See cache_check_executable how to obtain binaries.
-    #
-    # cache_dump_executable = "@CACHE_DUMP_CMD@"
-
-    # The method, if any, used to define a local system ID on this host.
-    # By placing the same system ID on a Volume Group you can prevent
-    # other co-operating hosts that see the same storage devices (each 
-    # with a different system ID) from accessing the same Volume Group.
-    #
-    # Set this to one of: none, machineid, uname, lvmlocal, or file.
-    #
-    # N.B. Do not use this feature without reading 'man lvmsystemid' to
-    # understand the correct ways to use it and its limitations.
-    #
-    # system_id_source = "none"
-    #
-    # Obtain the system ID from the "system_id" setting in the "local"
-    # section of a configuration file such as @DEFAULT_SYS_DIR@/lvmlocal.conf.
-    #
-    # system_id_source = "lvmlocal"
-    #
-    # Set the system ID from the hostname of the system.
-    # System IDs beginning "localhost" are not permitted.
-    #
-    # system_id_source = "uname"
-    #
-    # Use the contents of the file @DEFAULT_SYS_DIR@/machine-id
-    # to set the system ID.  Some systems create this file at
-    # installation time - see 'man machine-id'.
-    #
-    # system_id_source = "machineid"
-    #
-    # Use the contents of an alternative file to set the system ID.
-    # Comments starting with the character # are ignored.
-    #
-    # system_id_source = "file"
-    # system_id_file = "/etc/systemid"
-}
-
-activation {
-    # Set to 1 to perform internal checks on the operations issued to
-    # libdevmapper.  Useful for debugging problems with activation.
-    # Some of the checks may be expensive, so it's best to use this
-    # only when there seems to be a problem.
-    checks = 0
-
-    # Set to 0 to disable udev synchronisation (if compiled into the binaries).
-    # Processes will not wait for notification from udev.
-    # They will continue irrespective of any possible udev processing
-    # in the background.  You should only use this if udev is not running
-    # or has rules that ignore the devices LVM2 creates.
-    # The command line argument --nodevsync takes precedence over this setting.
-    # If set to 1 when udev is not running, and there are LVM2 processes
-    # waiting for udev, run 'dmsetup udevcomplete_all' manually to wake them up.
-    udev_sync = 1
-
-    # Set to 0 to disable the udev rules installed by LVM2 (if built with
-    # --enable-udev_rules). LVM2 will then manage the /dev nodes and symlinks
-    # for active logical volumes directly itself.
-    # N.B. Manual intervention may be required if this setting is changed
-    # while any logical volumes are active.
-    udev_rules = 1
-
-    # Set to 1 for LVM2 to verify operations performed by udev. This turns on
-    # additional checks (and if necessary, repairs) on entries in the device
-    # directory after udev has completed processing its events. 
-    # Useful for diagnosing problems with LVM2/udev interactions.
-    verify_udev_operations = 0
-
-    # If set to 1 and if deactivation of an LV fails, perhaps because
-    # a process run from a quick udev rule temporarily opened the device,
-    # retry the operation for a few seconds before failing.
-    retry_deactivation = 1
-
-    # How to fill in missing stripes if activating an incomplete volume.
-    # Using "error" will make inaccessible parts of the device return
-    # I/O errors on access.  You can instead use a device path, in which 
-    # case, that device will be used to in place of missing stripes.
-    # But note that using anything other than "error" with mirrored 
-    # or snapshotted volumes is likely to result in data corruption.
-    missing_stripe_filler = "error"
-
-    # The linear target is an optimised version of the striped target
-    # that only handles a single stripe.  Set this to 0 to disable this
-    # optimisation and always use the striped target.
-    use_linear_target = 1
-
-    # How much stack (in KB) to reserve for use while devices suspended
-    # Prior to version 2.02.89 this used to be set to 256KB
-    reserved_stack = 64
-
-    # How much memory (in KB) to reserve for use while devices suspended
-    reserved_memory = 8192
-
-    # Nice value used while devices suspended
-    process_priority = -18
-
-    # If volume_list is defined, each LV is only activated if there is a
-    # match against the list.
-    #
-    #   "vgname" and "vgname/lvname" are matched exactly.
-    #   "@tag" matches any tag set in the LV or VG.
-    #   "@*" matches if any tag defined on the host is also set in the LV or VG
-    #
-    # If any host tags exist but volume_list is not defined, a default
-    # single-entry list containing "@*" is assumed.
-    #
-    # volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
-
-    # If auto_activation_volume_list is defined, each LV that is to be
-    # activated with the autoactivation option (--activate ay/-a ay) is
-    # first checked against the list. There are two scenarios in which
-    # the autoactivation option is used:
-    #
-    #   - automatic activation of volumes based on incoming PVs. If all the
-    #     PVs making up a VG are present in the system, the autoactivation
-    #     is triggered. This requires lvmetad (global/use_lvmetad=1) and udev
-    #     to be running. In this case, "pvscan --cache -aay" is called
-    #     automatically without any user intervention while processing
-    #     udev events. Please, make sure you define auto_activation_volume_list
-    #     properly so only the volumes you want and expect are autoactivated.
-    #
-    #   - direct activation on command line with the autoactivation option.
-    #     In this case, the user calls "vgchange --activate ay/-a ay" or
-    #     "lvchange --activate ay/-a ay" directly.
-    #
-    # By default, the auto_activation_volume_list is not defined and all
-    # volumes will be activated either automatically or by using --activate ay/-a ay.
-    #
-    # N.B. The "activation/volume_list" is still honoured in all cases so even
-    # if the VG/LV passes the auto_activation_volume_list, it still needs to
-    # pass the volume_list for it to be activated in the end.
-
-    # If auto_activation_volume_list is defined but empty, no volumes will be
-    # activated automatically and --activate ay/-a ay will do nothing.
-    #
-    # auto_activation_volume_list = []
-
-    # If auto_activation_volume_list is defined and it's not empty, only matching
-    # volumes will be activated either automatically or by using --activate ay/-a ay.
-    #
-    #   "vgname" and "vgname/lvname" are matched exactly.
-    #   "@tag" matches any tag set in the LV or VG.
-    #   "@*" matches if any tag defined on the host is also set in the LV or VG
-    #
-    # auto_activation_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
-
-    # If read_only_volume_list is defined, each LV that is to be activated 
-    # is checked against the list, and if it matches, it is activated
-    # in read-only mode.  (This overrides '--permission rw' stored in the
-    # metadata.)
-    #
-    #   "vgname" and "vgname/lvname" are matched exactly.
-    #   "@tag" matches any tag set in the LV or VG.
-    #   "@*" matches if any tag defined on the host is also set in the LV or VG
-    #
-    # read_only_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
-
-    # Each LV can have an 'activation skip' flag stored persistently against it.
-    # During activation, this flag is used to decide whether such an LV is skipped.
-    # The 'activation skip' flag can be set during LV creation and by default it
-    # is automatically set for thin snapshot LVs. The 'auto_set_activation_skip'
-    # enables or disables this automatic setting of the flag while LVs are created.
-    # auto_set_activation_skip = 1
-
-    # Control error behavior when provisioned device becomes full.  This
-    # determines the default --errorwhenfull setting of new thin pools.
-    # The command line option --errorwhenfull takes precedence over this
-    # setting.  error_when_full 0 means --errorwhenfull n.
-    #
-    # error_when_full = 0
-
-    # For RAID or 'mirror' segment types, 'raid_region_size' is the
-    # size (in KiB) of each:
-    # - synchronization operation when initializing
-    # - each copy operation when performing a 'pvmove' (using 'mirror' segtype)
-    # This setting has replaced 'mirror_region_size' since version 2.02.99
-    raid_region_size = 512
-
-    # Setting to use when there is no readahead value stored in the metadata.
-    #
-    # "none" - Disable readahead.
-    # "auto" - Use default value chosen by kernel.
-    readahead = "auto"
-
-    # 'raid_fault_policy' defines how a device failure in a RAID logical
-    # volume is handled.  This includes logical volumes that have the following
-    # segment types: raid1, raid4, raid5*, and raid6*.
-    #
-    # In the event of a failure, the following policies will determine what
-    # actions are performed during the automated response to failures (when
-    # dmeventd is monitoring the RAID logical volume) and when 'lvconvert' is
-    # called manually with the options '--repair' and '--use-policies'.
-    #
-    # "warn"	- Use the system log to warn the user that a device in the RAID
-    # 		  logical volume has failed.  It is left to the user to run
-    #		  'lvconvert --repair' manually to remove or replace the failed
-    #		  device.  As long as the number of failed devices does not
-    #		  exceed the redundancy of the logical volume (1 device for
-    #		  raid4/5, 2 for raid6, etc) the logical volume will remain
-    #		  usable.
-    #
-    # "allocate" - Attempt to use any extra physical volumes in the volume
-    # 		  group as spares and replace faulty devices.
-    #
-    raid_fault_policy = "warn"
-
-    # 'mirror_image_fault_policy' and 'mirror_log_fault_policy' define
-    # how a device failure affecting a mirror (of "mirror" segment type) is
-    # handled.  A mirror is composed of mirror images (copies) and a log.
-    # A disk log ensures that a mirror does not need to be re-synced
-    # (all copies made the same) every time a machine reboots or crashes.
-    #
-    # In the event of a failure, the specified policy will be used to determine
-    # what happens. This applies to automatic repairs (when the mirror is being
-    # monitored by dmeventd) and to manual lvconvert --repair when
-    # --use-policies is given.
-    #
-    # "remove" - Simply remove the faulty device and run without it.  If
-    #            the log device fails, the mirror would convert to using
-    #            an in-memory log.  This means the mirror will not
-    #            remember its sync status across crashes/reboots and
-    #            the entire mirror will be re-synced.  If a
-    #            mirror image fails, the mirror will convert to a
-    #            non-mirrored device if there is only one remaining good
-    #            copy.
-    #
-    # "allocate" - Remove the faulty device and try to allocate space on
-    #            a new device to be a replacement for the failed device.
-    #            Using this policy for the log is fast and maintains the
-    #            ability to remember sync state through crashes/reboots.
-    #            Using this policy for a mirror device is slow, as it
-    #            requires the mirror to resynchronize the devices, but it
-    #            will preserve the mirror characteristic of the device.
-    #            This policy acts like "remove" if no suitable device and
-    #            space can be allocated for the replacement.
-    #
-    # "allocate_anywhere" - Not yet implemented. Useful to place the log device
-    #            temporarily on same physical volume as one of the mirror
-    #            images. This policy is not recommended for mirror devices
-    #            since it would break the redundant nature of the mirror. This
-    #            policy acts like "remove" if no suitable device and space can
-    #            be allocated for the replacement.
-
-    mirror_log_fault_policy = "allocate"
-    mirror_image_fault_policy = "remove"
-
-    # 'snapshot_autoextend_threshold' and 'snapshot_autoextend_percent' define
-    # how to handle automatic snapshot extension. The former defines when the
-    # snapshot should be extended: when its space usage exceeds this many
-    # percent. The latter defines how much extra space should be allocated for
-    # the snapshot, in percent of its current size.
-    #
-    # For example, if you set snapshot_autoextend_threshold to 70 and
-    # snapshot_autoextend_percent to 20, whenever a snapshot exceeds 70% usage,
-    # it will be extended by another 20%. For a 1G snapshot, using up 700M will
-    # trigger a resize to 1.2G. When the usage exceeds 840M, the snapshot will
-    # be extended to 1.44G, and so on.
-    #
-    # Setting snapshot_autoextend_threshold to 100 disables automatic
-    # extensions. The minimum value is 50 (A setting below 50 will be treated
-    # as 50).
-
-    snapshot_autoextend_threshold = 100
-    snapshot_autoextend_percent = 20
-
-    # 'thin_pool_autoextend_threshold' and 'thin_pool_autoextend_percent' define
-    # how to handle automatic pool extension. The former defines when the
-    # pool should be extended: when its space usage exceeds this many
-    # percent. The latter defines how much extra space should be allocated for
-    # the pool, in percent of its current size.
-    #
-    # For example, if you set thin_pool_autoextend_threshold to 70 and
-    # thin_pool_autoextend_percent to 20, whenever a pool exceeds 70% usage,
-    # it will be extended by another 20%. For a 1G pool, using up 700M will
-    # trigger a resize to 1.2G. When the usage exceeds 840M, the pool will
-    # be extended to 1.44G, and so on.
-    #
-    # Setting thin_pool_autoextend_threshold to 100 disables automatic
-    # extensions. The minimum value is 50 (A setting below 50 will be treated
-    # as 50).
-
-    thin_pool_autoextend_threshold = 100
-    thin_pool_autoextend_percent = 20
-
-    # While activating devices, I/O to devices being (re)configured is
-    # suspended, and as a precaution against deadlocks, LVM2 needs to pin
-    # any memory it is using so it is not paged out.  Groups of pages that
-    # are known not to be accessed during activation need not be pinned
-    # into memory.  Each string listed in this setting is compared against
-    # each line in /proc/self/maps, and the pages corresponding to any
-    # lines that match are not pinned.  On some systems locale-archive was
-    # found to make up over 80% of the memory used by the process.
-    # mlock_filter = [ "locale/locale-archive", "gconv/gconv-modules.cache" ]
-
-    # Set to 1 to revert to the default behaviour prior to version 2.02.62
-    # which used mlockall() to pin the whole process's memory while activating
-    # devices.
-    use_mlockall = 0
-
-    # Monitoring is enabled by default when activating logical volumes.
-    # Set to 0 to disable monitoring or use the --ignoremonitoring option.
-    monitoring = 1
-
-    # When pvmove or lvconvert must wait for the kernel to finish
-    # synchronising or merging data, they check and report progress
-    # at intervals of this number of seconds.  The default is 15 seconds.
-    # If this is set to 0 and there is only one thing to wait for, there
-    # are no progress reports, but the process is awoken immediately the
-    # operation is complete.
-    polling_interval = 15
-
-    # 'activation_mode' determines how Logical Volumes are activated if
-    # any devices are missing.  Possible settings are:
-    #
-    #	"complete" -  Only allow activation of an LV if all of the Physical
-    #		      Volumes it uses are present.  Other PVs in the Volume
-    #		      Group may be missing.
-    #
-    #	"degraded" -  Like "complete", but additionally RAID Logical Volumes of
-    #		      segment type raid1, raid4, raid5, radid6 and raid10 will
-    #		      be activated if there is no data loss, i.e. they have
-    #		      sufficient redundancy to present the entire addressable
-    #		      range of the Logical Volume.
-    #
-    #	"partial"  -  Allows the activation of any Logical Volume even if
-    #		      a missing or failed PV could cause data loss with a
-    #		      portion of the Logical Volume inaccessible.
-    #		      This setting should not normally be used, but may
-    #		      sometimes assist with data recovery.
-    #
-    # This setting was introduced in LVM version 2.02.108.  It corresponds
-    # with the '--activationmode' option for lvchange and vgchange.
-    activation_mode = "degraded"
-}
-
-# Report settings.
-#
-# report {
-    # If compact output is enabled, fields which don't have value
-    # set for any of the rows reported are skipped on output. Compact
-    # output is applicable only if report is buffered (report/buffered=1).
-    # compact_output=0
-
-    # Align columns on report output.
-    # aligned=1
-
-    # When buffered reporting is used, the report's content is appended
-    # incrementally to include each object being reported until the report
-    # is flushed to output which normally happens at the end of command
-    # execution. Otherwise, if buffering is not used, each object is
-    # reported as soon as its processing is finished.
-    # buffered=1
-
-    # Show headings for columns on report.
-    # headings=1
-
-    # A separator to use on report after each field.
-    # separator=" "
-
-    # A separator to use for list items when reported.
-    # list_item_separator=","
-
-    # Use a field name prefix for each field reported.
-    # prefixes=0
-
-    # Quote field values when using field name prefixes.
-    # quoted=1
-
-    # Output each column as a row. If set, this also implies report/prefixes=1.
-    # colums_as_rows=0
-
-    # Use binary values "0" or "1" instead of descriptive literal values for
-    # columns that have exactly two valid values to report (not counting the
-    # "unknown" value which denotes that the value could not be determined).
-    #
-    # binary_values_as_numeric = 0
-
-    # Comma separated list of columns to sort by when reporting 'lvm devtypes' command.
-    # See 'lvm devtypes -o help' for the list of possible fields.
-    # devtypes_sort="devtype_name"
-
-    # Comma separated list of columns to report for 'lvm devtypes' command.
-    # See 'lvm devtypes -o help' for the list of possible fields.
-    # devtypes_cols="devtype_name,devtype_max_partitions,devtype_description"
-
-    # Comma separated list of columns to report for 'lvm devtypes' command in verbose mode.
-    # See 'lvm devtypes -o help' for the list of possible fields.
-    # devtypes_cols_verbose="devtype_name,devtype_max_partitions,devtype_description"
-
-    # Comma separated list of columns to sort by when reporting 'lvs' command.
-    # See 'lvs -o help' for the list of possible fields.
-    # lvs_sort="vg_name,lv_name"
-
-    # Comma separated list of columns to report for 'lvs' command.
-    # See 'lvs -o help' for the list of possible fields.
-    # lvs_cols="lv_name,vg_name,lv_attr,lv_size,pool_lv,origin,data_percent,metadata_percent,move_pv,mirror_log,copy_percent,convert_lv"
-
-    # Comma separated list of columns to report for 'lvs' command in verbose mode.
-    # See 'lvs -o help' for the list of possible fields.
-    # lvs_cols_verbose="lv_name,vg_name,seg_count,lv_attr,lv_size,lv_major,lv_minor,lv_kernel_major,lv_kernel_minor,pool_lv,origin,data_percent,metadata_percent,move_pv,copy_percent,mirror_log,convert
-
-    # Comma separated list of columns to sort by when reporting 'vgs' command.
-    # See 'vgs -o help' for the list of possible fields.
-    # vgs_sort="vg_name"
-
-    # Comma separated list of columns to report for 'vgs' command.
-    # See 'vgs -o help' for the list of possible fields.
-    # vgs_cols="vg_name,pv_count,lv_count,snap_count,vg_attr,vg_size,vg_free"
-
-    # Comma separated list of columns to report for 'vgs' command in verbose mode.
-    # See 'vgs -o help' for the list of possible fields.
-    # vgs_cols_verbose="vg_name,vg_attr,vg_extent_size,pv_count,lv_count,snap_count,vg_size,vg_free,vg_uuid,vg_profile"
-
-    # Comma separated list of columns to sort by when reporting 'pvs' command.
-    # See 'pvs -o help' for the list of possible fields.
-    # pvs_sort="pv_name"
-
-    # Comma separated list of columns to report for 'pvs' command.
-    # See 'pvs -o help' for the list of possible fields.
-    # pvs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free"
-
-    # Comma separated list of columns to report for 'pvs' command in verbose mode.
-    # See 'pvs -o help' for the list of possible fields.
-    # pvs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,dev_size,pv_uuid"
-
-    # Comma separated list of columns to sort by when reporting 'lvs --segments' command.
-    # See 'lvs --segments -o help' for the list of possible fields.
-    # segs_sort="vg_name,lv_name,seg_start"
-
-    # Comma separated list of columns to report for 'lvs --segments' command.
-    # See 'lvs --segments  -o help' for the list of possible fields.
-    # segs_cols="lv_name,vg_name,lv_attr,stripes,segtype,seg_size"
-
-    # Comma separated list of columns to report for 'lvs --segments' command in verbose mode.
-    # See 'lvs --segments -o help' for the list of possible fields.
-    # segs_cols_verbose="lv_name,vg_name,lv_attr,seg_start,seg_size,stripes,segtype,stripesize,chunksize"
-
-    # Comma separated list of columns to sort by when reporting 'pvs --segments' command.
-    # See 'pvs --segments -o help' for the list of possible fields.
-    # pvsegs_sort="pv_name,pvseg_start"
-
-    # Comma separated list of columns to sort by when reporting 'pvs --segments' command.
-    # See 'pvs --segments -o help' for the list of possible fields.
-    # pvsegs_cols="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size"
-
-    # Comma separated list of columns to sort by when reporting 'pvs --segments' command in verbose mode.
-    # See 'pvs --segments -o help' for the list of possible fields.
-    # pvsegs_cols_verbose="pv_name,vg_name,pv_fmt,pv_attr,pv_size,pv_free,pvseg_start,pvseg_size,lv_name,seg_start_pe,segtype,seg_pe_ranges"
-#}
-
-####################
-# Advanced section #
-####################
-
-# Metadata settings
-#
-# metadata {
-    # Default number of copies of metadata to hold on each PV.  0, 1 or 2.
-    # You might want to override it from the command line with 0 
-    # when running pvcreate on new PVs which are to be added to large VGs.
-
-    # pvmetadatacopies = 1
-
-    # Default number of copies of metadata to maintain for each VG.
-    # If set to a non-zero value, LVM automatically chooses which of
-    # the available metadata areas to use to achieve the requested
-    # number of copies of the VG metadata.  If you set a value larger
-    # than the the total number of metadata areas available then
-    # metadata is stored in them all.
-    # The default value of 0 ("unmanaged") disables this automatic
-    # management and allows you to control which metadata areas
-    # are used at the individual PV level using 'pvchange
-    # --metadataignore y/n'.
-
-    # vgmetadatacopies = 0
-
-    # Approximate default size of on-disk metadata areas in sectors.
-    # You should increase this if you have large volume groups or
-    # you want to retain a large on-disk history of your metadata changes.
-
-    # pvmetadatasize = 255
-
-    # List of directories holding live copies of text format metadata.
-    # These directories must not be on logical volumes!
-    # It's possible to use LVM2 with a couple of directories here,
-    # preferably on different (non-LV) filesystems, and with no other 
-    # on-disk metadata (pvmetadatacopies = 0). Or this can be in
-    # addition to on-disk metadata areas.
-    # The feature was originally added to simplify testing and is not
-    # supported under low memory situations - the machine could lock up.
-    #
-    # Never edit any files in these directories by hand unless you
-    # you are absolutely sure you know what you are doing! Use
-    # the supplied toolset to make changes (e.g. vgcfgrestore).
-
-    # dirs = [ "/etc/lvm/metadata", "/mnt/disk2/lvm/metadata2" ]
-#}
-
-# Event daemon
-#
-dmeventd {
-    # mirror_library is the library used when monitoring a mirror device.
-    #
-    # "libdevmapper-event-lvm2mirror.so" attempts to recover from
-    # failures.  It removes failed devices from a volume group and
-    # reconfigures a mirror as necessary. If no mirror library is
-    # provided, mirrors are not monitored through dmeventd.
-
-    mirror_library = "libdevmapper-event-lvm2mirror.so"
-
-    # snapshot_library is the library used when monitoring a snapshot device.
-    #
-    # "libdevmapper-event-lvm2snapshot.so" monitors the filling of
-    # snapshots and emits a warning through syslog when the use of
-    # the snapshot exceeds 80%. The warning is repeated when 85%, 90% and
-    # 95% of the snapshot is filled.
-
-    snapshot_library = "libdevmapper-event-lvm2snapshot.so"
-
-    # thin_library is the library used when monitoring a thin device.
-    #
-    # "libdevmapper-event-lvm2thin.so" monitors the filling of
-    # pool and emits a warning through syslog when the use of
-    # the pool exceeds 80%. The warning is repeated when 85%, 90% and
-    # 95% of the pool is filled.
-
-    thin_library = "libdevmapper-event-lvm2thin.so"
-
-    # Full path of the dmeventd binary.
-    #
-    # executable = "@DMEVENTD_PATH@"
-}
diff --git a/conf/lvmlocal.conf.base b/conf/lvmlocal.conf.base
new file mode 100644
index 0000000..e2a9e2f
--- /dev/null
+++ b/conf/lvmlocal.conf.base
@@ -0,0 +1,19 @@
+# This is a local configuration file template for the LVM2 system
+# which should be installed as @DEFAULT_SYS_DIR@/lvmlocal.conf .
+#
+# Refer to 'man lvm.conf' for information about the file layout.
+#
+# To put this file in a different directory and override
+# @DEFAULT_SYS_DIR@ set the environment variable LVM_SYSTEM_DIR before
+# running the tools.
+#
+# The lvmlocal.conf file is normally expected to contain only the
+# "local" section which contains settings that should not be shared or
+# repeated among different hosts.  (But if other sections are present,
+# they *will* get processed.  Settings in this file override equivalent
+# ones in lvm.conf and are in turn overridden by ones in any enabled
+# lvm_<tag>.conf files.)
+#
+# Please take care that each setting only appears once if uncommenting
+# example settings in this file and never copy this file between hosts.
+
diff --git a/conf/lvmlocal.conf.in b/conf/lvmlocal.conf.in
index 48965e4..e69de29 100644
--- a/conf/lvmlocal.conf.in
+++ b/conf/lvmlocal.conf.in
@@ -1,54 +0,0 @@
-# This is a local configuration file template for the LVM2 system
-# which should be installed as @DEFAULT_SYS_DIR@/lvmlocal.conf .
-#
-# This file allows you to assign a unique identity to a host running
-# LVM2 that is permitted to access storage devices visible to more than
-# one machine simultaneously.  
-#
-# You must ensure that every such host uses a different system_id
-# identifier, otherwise LVM2 cannot protect you from simultaneous
-# access from multiple hosts and possible data corruption.
-#
-# Refer to 'man lvmsystemid' for information about the correct ways
-# to use this and its limitations.
-#
-# Refer to 'man lvm.conf' for information about the file layout.
-#
-# To put this file in a different directory and override
-# @DEFAULT_SYS_DIR@ set the environment variable LVM_SYSTEM_DIR before
-# running the tools.
-#
-# The lvmlocal.conf file is normally expected to contain only the
-# "local" section which contains settings that should not be shared or
-# repeated among different hosts.  (But if other sections are present,
-# they *will* get processed.  Settings in this file override equivalent
-# ones in lvm.conf and are in turn overridden by ones in any enabled
-# lvm_<tag>.conf files.)
-#
-# Please take care that each setting only appears once if uncommenting
-# example settings in this file and never copy this file between
-# hosts to avoid accidentally assigning the same system ID to
-# more than one host!
-
-local {
-    # This defines the system ID of the local host.  This is used
-    # when global/system_id_source is set to "lvmlocal" in the main
-    # configuration file, conventionally @DEFAULT_SYS_DIR@/lvm.conf.  
-    # When used, it must be set to a unique value - often a hostname -
-    # across all the hosts sharing access to the storage.
-    #
-    # By default, no system_id is set.
-    # system_id = ""
-    #
-    # Set the system_id to the string "host1".
-    # system_id = "host1"
-
-    # This defines a list of extra system_ids other than the local
-    # system_id that the local host is allowed to access.  These are
-    # used for all values of global/system_id_source except "none".
-    #
-    # Only use this if you have read 'man lvmsystemid' and you are sure
-    # you understand why you need to use it!
-    #
-    # extra_system_ids = []
-}
diff --git a/make.tmpl.in b/make.tmpl.in
index 322e33b..ed6b522 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -282,6 +282,7 @@ POTFILES = $(SOURCES:%.c=%.pot)
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
+.PHONY: $(SUBDIRS.generate) generate
 
 SUBDIRS.device-mapper := $(SUBDIRS:=.device-mapper)
 SUBDIRS.install := $(SUBDIRS:=.install)
@@ -342,6 +343,9 @@ $(SUBDIRS.pofile):
 	$(MAKE) -C $(@:.pofile=) pofile
 endif
 
+$(SUBDIRS.generate):
+	$(MAKE) -C $(@:.generate=) generate
+
 ifneq ("$(CFLOW_LIST_TARGET)", "")
 CLEAN_CFLOW += $(CFLOW_LIST_TARGET)
 $(CFLOW_LIST_TARGET): $(CFLOW_LIST)
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 288bc42..074e2e9 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -155,502 +155,48 @@ An empty array is acceptable.
 Strings with spaces must be enclosed in double quotes, single words that start
 with a letter can be left unquoted.
 
-.SH SECTIONS
-.LP
-The sections that may be present in the file are:
-.TP
-\fBdevices\fP \(em Device settings
-.IP
-\fBdir\fP \(em Directory in which to create volume group device nodes.
-Defaults to "/dev".  Commands also accept this as a prefix on volume
-group names.
-.IP
-\fBscan\fP \(em List of directories to scan recursively for
-LVM physical volumes.
-Devices in directories outside this hierarchy will be ignored.
-Defaults to "/dev".
-.IP
-\fBpreferred_names\fP \(em List of patterns compared in turn against
-all the pathnames referencing the same device in in the scanned directories.
-The pathname that matches the earliest pattern in the list is the
-one used in any output.  As an example, if device-mapper multipathing
-is used, the following will select multipath device names:
+.SH SETTINGS
+
+The
+.B lvm dumpconfig
+command prints the LVM configuration settings in various ways.
+See the man page
+.BR lvm-dumpconfig (8).
+
+Command to print a list of all possible config settings, with their
+default values:
 .br
-\fBdevices { preferred_names = [ "^/dev/mapper/mpath" ] }\fP
-.IP
-\fBfilter\fP \(em List of patterns to apply to devices found by a scan.
-Patterns are regular expressions delimited by any character and preceded
-by \fBa\fP (for accept) or \fBr\fP (for reject).  The list is traversed
-in order, and the first regex that matches determines if the device
-will be accepted or rejected (ignored).  Devices that don't match
-any patterns are accepted. If you want to reject patterns that
-don't match, end the list with "r/.*/".
-If there are several names for the same device (e.g. symbolic links
-in /dev), if the first matching pattern in the list for any of the names is an
-\fBa\fP pattern, the device is accepted; otherwise if the first matching
-pattern in the list for any of the names is an \fBr\fP pattern it is rejected;
-otherwise it is accepted.  As an example, to ignore /dev/cdrom you could use:
+.B lvm dumpconfig \-\-type default
+
+Command to print a list of all possible config settings, with their
+default values, and a full description of each as a comment:
 .br
-\fBdevices { filter=["r|cdrom|"] }\fP
-.IP
-\fBglobal_filter\fP \(em Since "filter" might get overridden from the command line, it
-is not suitable for system-wide device filtering (udev rules, lvmetad). To hide
-devices from LVM-specific udev processing and/or from lvmetad, you need to set
-global_filter. The syntax is the same as for normal "filter" above. Devices that
-fail the global_filter are not even opened by LVM.
-.IP
-\fBcache_dir\fP \(em Persistent filter cache file directory.
-Defaults to "#DEFAULT_CACHE_DIR#".
-.IP
-\fBwrite_cache_state\fP \(em Set to 0 to disable the writing out of the
-persistent filter cache file when \fBlvm\fP exits.
-Defaults to 1.
-.IP
-\fBtypes\fP \(em List of pairs of additional acceptable block device types
-found in /proc/devices together with maximum (non-zero) number of
-partitions (normally 16).  By default, LVM2 supports ide, sd, md, loop,
-dasd, dac960, nbd, ida, cciss, ubd, ataraid, drbd, power2, i2o_block
-and iseries/vd.  Block devices with major
-numbers of different types are ignored by LVM2.
-Example: \fBtypes = ["fd", 16]\fP.
-To create physical volumes on device-mapper volumes
-created outside LVM2, perhaps encrypted ones from \fBcryptsetup\fP,
-you'll need \fBtypes = ["device-mapper", 16]\fP.  But if you do this,
-be careful to avoid recursion within LVM2.  The figure for number
-of partitions is not currently used in LVM2 - and might never be.
-.IP
-\fBsysfs_scan\fP \(em If set to 1 and your kernel supports sysfs and
-it is mounted, sysfs will be used as a quick way of filtering out
-block devices that are not present.
-.IP
-\fBmd_component_detection\fP \(em If set to 1, LVM2 will ignore devices
-used as components of software RAID (md) devices by looking for md
-superblocks. This doesn't always work satisfactorily e.g. if a device
-has been reused without wiping the md superblocks first.
-.IP
-\fBmd_chunk_alignment\fP \(em If set to 1, and a Physical Volume is placed
-directly upon an md device, LVM2 will align its data blocks with the
-md device's stripe-width.
-.IP
-\fBdata_alignment_detection\fP \(em If set to 1, and your kernel provides
-topology information in sysfs for the Physical Volume, the start of data
-area will be aligned on a multiple of the ???minimum_io_size??? or
-???optimal_io_size??? exposed in sysfs.  minimum_io_size is the smallest
-request the device can perform without incurring a read-modify-write
-penalty (e.g. MD's chunk size).  optimal_io_size is the device's
-preferred unit of receiving I/O (e.g. MD's stripe width).  minimum_io_size
-is used if optimal_io_size is undefined (0).  If both \fBmd_chunk_alignment\fP
-and \fBdata_alignment_detection\fP are enabled the result of
-\fBdata_alignment_detection\fP is used.
-.IP
-\fBdata_alignment\fP \(em Default alignment (in KB) of start of data area
-when creating a new Physical Volume using the \fBlvm2\fP format.
-If a Physical Volume is placed directly upon an md device and
-\fBmd_chunk_alignment\fP or \fBdata_alignment_detection\fP is enabled
-this parameter is ignored.  Set to 0 to use the default alignment of
-64KB or the page size, if larger.
-.IP
-\fBdata_alignment_offset_detection\fP \(em If set to 1, and your kernel
-provides topology information in sysfs for the Physical Volume, the
-start of the aligned data area of the Physical Volume will be shifted
-by the alignment_offset exposed in sysfs.
-.sp
-To see the location of the first Physical Extent of an existing Physical Volume
-use \fBpvs \-o +pe_start\fP .  It will be a multiple of the requested
-\fBdata_alignment\fP plus the alignment_offset from
-\fBdata_alignment_offset_detection\fP (if enabled) or the pvcreate
-commandline.
-.IP
-\fBdisable_after_error_count\fP \(em During each LVM operation errors received
-from each device are counted.  If the counter of a particular device exceeds
-the limit set here, no further I/O is sent to that device for the remainder of
-the respective operation. Setting the parameter to 0 disables the counters
-altogether.
-.IP
-\fBpv_min_size\fP \(em
-Minimal size (in KB) of the block device which can be used as a PV.
-In clustered environment all nodes have to use the same value.
-Any value smaller than 512KB is ignored.  Up to and include version 2.02.84
-the default was 512KB.  From 2.02.85 onwards it was changed to 2MB to
-avoid floppy drives by default.
-.IP
-\fBissue_discards\fP \(em
-Issue discards to a logical volumes's underlying physical volume(s) when the
-logical volume is no longer using the physical volumes' space (e.g. lvremove,
-lvreduce, etc).  Discards inform the storage that a region is no longer in use.
-Storage that supports discards advertise the protocol specific way discards
-should be issued by the kernel (TRIM, UNMAP, or WRITE SAME with UNMAP bit set).
-Not all storage will support or benefit from discards but SSDs and thinly
-provisioned LUNs generally do.  If set to 1, discards will only be issued if
-both the storage and kernel provide support.
-.IP
-.TP
-\fBallocation\fP \(em Space allocation policies
-.IP
-\fBcling_tag_list\fP \(em List of PV tags matched by the \fBcling\fP allocation policy.
-.IP
-When searching for free space to extend an LV, the \fBcling\fP
-allocation policy will choose space on the same PVs as the last
-segment of the existing LV.  If there is insufficient space and a
-list of tags is defined here, it will check whether any of them are
-attached to the PVs concerned and then seek to match those PV tags
-between existing extents and new extents.
-.IP
-The @ prefix for tags is required.
-Use the special tag "@*" as a wildcard to match any PV tag and so use
-all PV tags for this purpose.
-.IP
-For example, LVs are mirrored between two sites within a single VG.
-PVs are tagged with either @site1 or @site2 to indicate where
-they are situated and these two PV tags are selected for use with this
-allocation policy:
-.IP
-cling_tag_list = [ "@site1", "@site2" ]
-.IP
-\fBcache_pool_cachemode\fP \(em Cache mode for new cache pools.
-.IP
-This is the default cache mode a new cache pool will be given.
-Valid cache modes are:
-\fBwritethrough\fP - Data blocks are immediately written from the
-cache to disk.
-\fBwriteback\fP - Data blocks are written from the cache
-back to disk after some delay to improve performance.
-.TP
-\fBlog\fP \(em Default log settings
-.IP
-\fBfile\fP \(em Location of log file.  If this entry is not present, no
-log file is written.
-.IP
-\fBoverwrite\fP \(em Set to 1 to overwrite the log file each time a tool
-is invoked.  By default tools append messages to the log file.
-.IP
-\fBlevel\fP \(em Log level (0-9) of messages to write to the file.
-9 is the most verbose; 0 should produce no output.
-.IP
-\fBverbose\fP \(em Default level (0-3) of messages sent to stdout or stderr.
-3 is the most verbose; 0 should produce the least output.
-.IP
-\fBsilent\fP \(em Set to 1 to suppress all non-essential tool output.
-When set, display and reporting tools will still write the requested
-device properties to standard output, but messages confirming that
-something was or wasn't changed will be reduced to the 'verbose' level
-and not appear unless \-v is supplied.
-.IP
-\fBsyslog\fP \(em Set to 1 (the default) to send log messages through syslog.
-Turn off by setting to 0.  If you set to an integer greater than one,
-this is used - unvalidated - as the facility.  The default is LOG_USER.
-See /usr/include/sys/syslog.h for safe facility values to use.
-For example, LOG_LOCAL0 might be 128.
-.IP
-\fBindent\fP \(em When set to 1 (the default) messages are indented
-according to their severity, two spaces per level.
-Set to 0 to turn off indentation.
-.IP
-\fBcommand_names\fP \(em When set to 1, the command name is used as a
-prefix for each message.
-Default is 0 (off).
-.IP
-\fBprefix\fP \(em Prefix used for all messages (after the command name).
-Default is two spaces.
-.IP
-\fBactivation\fP \(em Set to 1 to log messages while
-devices are suspended during activation.
-Only set this temporarily while debugging a problem because
-in low memory situations this setting can cause your machine to lock up.
-.TP
-\fBbackup\fP \(em Configuration for metadata backups.
-.IP
-\fBarchive_dir\fP \(em Directory used for automatic metadata archives.
-Backup copies of former metadata for each volume group are archived here.
-Defaults to "#DEFAULT_ARCHIVE_DIR#".
-.IP
-\fBbackup_dir\fP \(em Directory used for automatic metadata backups.
-A single backup copy of the current metadata for each volume group
-is stored here.
-Defaults to "#DEFAULT_BACKUP_DIR#".
-.IP
-\fBarchive\fP \(em Whether or not tools automatically archive existing
-metadata into \fBarchive_dir\fP before making changes to it.
-Default is 1 (automatic archives enabled).
-Set to 0 to disable.
-Disabling this might make metadata recovery difficult or impossible
-if something goes wrong.
-.IP
-\fBbackup\fP \(em Whether or not tools make an automatic backup
-into \fBbackup_dir\fP after changing metadata.
-Default is 1 (automatic backups enabled).  Set to 0 to disable.
-Disabling this might make metadata recovery difficult or impossible
-if something goes wrong.
-.IP
-\fBretain_min\fP \(em Minimum number of archives to keep.
-Defaults to 10.
-.IP
-\fBretain_days\fP \(em Minimum number of days to keep archive files.
-Defaults to 30.
-.TP
-\fBshell\fP \(em LVM2 built-in readline shell settings
-.IP
-\fBhistory_size\fP \(em Maximum number of lines of shell history to retain (default 100) in $HOME/.lvm_history
-.TP
-\fBglobal\fP \(em Global settings
-.IP
-\fBtest\fP \(em If set to 1, run tools in test mode i.e. no changes to
-the on-disk metadata will get made.  It's equivalent to having the
--t option on every command.
-.IP
-\fBactivation\fP \(em Set to 0 to turn off all communication with
-the device-mapper driver.  Useful if you want to manipulate logical
-volumes while device-mapper is not present in your kernel.
-.IP
-\fBproc\fP \(em Mount point of proc filesystem.
-Defaults to /proc.
-.IP
-\fBumask\fP \(em File creation mask for any files and directories created.
-Interpreted as octal if the first digit is zero.
-Defaults to 077.
-Use 022 to allow other users to read the files by default.
-.IP
-\fBformat\fP \(em The default value of \fB\-\-metadatatype\fP used
-to determine which format of metadata to use when creating new
-physical volumes and volume groups. \fBlvm1\fP or \fBlvm2\fP.
-.IP
-\fBfallback_to_lvm1\fP \(em Set this to 1 if you need to
-be able to switch between 2.4 kernels using LVM1 and kernels
-including device-mapper.
-The LVM2 tools should be installed as normal and
-the LVM1 tools should be installed with a .lvm1 suffix e.g.
-vgscan.lvm1.
-If an LVM2 tool is then run but unable to communicate
-with device-mapper, it will automatically invoke the equivalent LVM1
-version of the tool.  Note that for LVM1 tools to
-manipulate physical volumes and volume groups created by LVM2 you
-must use \fB\-\-metadataformat lvm1\fP when creating them.
-.IP
-\fBlibrary_dir\fP \(em A directory searched for LVM2's shared libraries
-ahead of the places \fBdlopen\fP (3) searches.
-.IP
-\fBformat_libraries\fP \(em A list of shared libraries to load that contain
-code to process different formats of metadata. For example, liblvm2formatpool.so
-is needed to read GFS pool metadata if LVM2 was configured \fB\-\-with-pool=shared\fP.
-.IP
-\fBlocking_type\fP \(em What type of locking to use.
-1 is the default, which use flocks on files in \fBlocking_dir\fP
-(see below) to
-avoid conflicting LVM2 commands running concurrently on a single
-machine. 0 disables locking and risks corrupting your metadata.
-If set to 2, the tools will load the external \fBlocking_library\fP
-(see below).
-If the tools were configured \fB\-\-with-cluster=internal\fP
-(the default) then 3 means to use built-in cluster-wide locking.
-Type 4 enforces read-only metadata and forbids any operations that
-might want to modify Volume Group metadata.
-All changes to logical volumes and their states are communicated
-using locks.
-.IP
-\fBwait_for_locks\fP \(em When set to 1, the default, the tools
-wait if a lock request cannot be satisfied immediately.
-When set to 0, the operation is aborted instead.
-.IP
-\fBlocking_dir\fP \(em The directory LVM2 places its file locks
-if \fBlocking_type\fP is set to 1.  The default is \fB/var/lock/lvm\fP.
-.IP
-\fBlocking_library\fP \(em The name of the external locking
-library to load if \fBlocking_type\fP is set to 2.
-The default is \fBliblvm2clusterlock.so\fP.  If you need to write
-such a library, look at the lib/locking source code directory.
-.IP
-\fBuse_lvmetad\fP \(em Whether to use (trust) a running instance of lvmetad. If
-this is set to 0, all commands fall back to the usual scanning mechanisms. When
-set to 1 \fBand\fP when lvmetad is running (it is not auto-started), the volume
-group metadata and PV state flags are obtained from the lvmetad instance and no
-scanning is done by the individual commands. In a setup with lvmetad, lvmetad
-udev rules \fBmust\fP be set up for LVM to work correctly. Without proper udev
-rules, all changes in block device configuration will be \fBignored\fP until a
-manual 'pvscan \-\-cache' is performed.
+.B lvm dumpconfig \-\-type default --withfullcomments
+
+Command to print a list of all possible config settings, with their
+current values (configured, non-default values are shown):
 .br
-If lvmetad has been running while use_lvmetad was 0, it \fBMUST\fP be stopped before
-changing use_lvmetad to 1 and started again afterwards.
-.TP
-\fBtags\fP \(em Host tag settings
-.IP
-\fBhosttags\fP \(em If set to 1, create a host tag with the machine name.
-Setting this to 0 does nothing, neither creating nor destroying any tag.
-The machine name used is the nodename as returned by \fBuname\fP (2).
-.IP
-Additional host tags to be set can be listed here as subsections.
-The @ prefix for tags is optional.
-Each of these host tag subsections can contain a \fBhost_list\fP
-array of host names. If any one of these entries matches the machine
-name exactly then the host tag gets defined on this particular host,
-otherwise it doesn't.
-.IP
-After lvm.conf has been processed, LVM2 works through each host
-tag that has been defined in turn, and if there is a configuration
-file called lvm_\fB<host_tag>\fP.conf it attempts to load it.
-The activation/volume_list, devices/filter and devices/types settings are merged
-(these all are lists), otherwise any settings read in override settings found in
-earlier files. Any additional host tags defined get appended to the search list,
-so in turn they can lead to further configuration files being processed.
-Use \fBlvm dumpconfig\fP to check the result of config
-file processing.
-.IP
-The following example always sets host tags \fBtag1\fP and
-sets \fBtag2\fP on machines fs1 and fs2:
-.IP
-tags { tag1 { } tag2 { host_list = [ "fs1", "fs2" ] } }
-.IP
-These options are useful if you are replicating configuration files
-around a cluster.  Use of \fBhosttags = 1\fP means every machine
-can have static and identical local configuration files yet use
-different settings and activate different logical volumes by
-default.  See also \fBvolume_list\fP below and \fB\-\-addtag\fP
-in \fBlvm\fP (8).
-.TP
-\fBactivation\fP \(em Settings affecting device-mapper activation
-.IP
-\fBmissing_stripe_filler\fP \(em When activating an incomplete logical
-volume in partial mode, this option dictates how the missing data is
-replaced.  A value of "error" will cause activation to create error
-mappings for the missing data, meaning that read access to missing
-portions of the volume will result in I/O errors. You can instead also
-use a device path, and in that case this device will be used in place of
-missing stripes. However, note that using anything other than
-"error" with mirrored or snapshotted volumes is likely to result in data
-corruption.  For instructions on how to create a device that always
-returns zeros, see \fBlvcreate\fP (8).
-.IP
-\fBmirror_region_size\fP \(em Unit size in KB for copy operations
-when mirroring.
-.IP
-\fBreadahead\fP \(em Used when there is no readahead value stored
-in the volume group metadata.  Set to \fBnone\fP to disable
-readahead in these circumstances or \fBauto\fP to use the default
-value chosen by the kernel.
-.IP
-\fBreserved_memory\fP, \fBreserved_stack\fP \(em How many KB to reserve
-for LVM2 to use while logical volumes are suspended.  If insufficient
-memory is reserved before suspension, there is a risk of machine deadlock.
-.IP
-\fBprocess_priority\fP \(em The nice value to use while devices are
-suspended.  This is set to a high priority so that logical volumes
-are suspended (with I/O generated by other processes to those
-logical volumes getting queued) for the shortest possible time.
-.IP
-\fBvolume_list\fP \(em This acts as a filter through which
-all requests to activate a logical volume on this machine
-are passed.  A logical volume is only activated if it matches
-an item in the list.  Tags must be preceded by @ and are checked
-against all tags defined in the logical volume and volume group
-metadata for a match.
-@* is short-hand to check every tag set on the host machine (see
-\fBtags\fP above).
-Logical volume and volume groups can also be included in the list
-by name e.g. vg00, vg00/lvol1.
-If this setting is not present but at least one host tag is defined
-then a default single-entry list containing @* is assumed.
-.IP
-\fBauto_activation_volume_list\fP \(em This acts as a filter through
-which all requests to autoactivate a logical volume on this machine
-are passed. A logical volume is autoactivated if it matches
-an item in the list. Volumes must also pass the \fBvolume_list\fP
-filter, if present. Tags must be preceded by @ and are checked against
-all tags defined in the logical volume and volume group metadata for
-a match. @* is short-hand to check every tag set on the host machine
-(see \fBtags\fP above).
-Logical volume and volume groups can also be included in the list
-by name e.g. vg00, vg00/lvol1.
-.IP
-\fBread_only_volume_list\fP \(em This acts as a filter through
-which all requests to activate a logical volume on this machine
-are passed.  A logical volume is activated in read-only mode (instead
-of read-write) if it matches an item in the list.  Volumes must first
-pass the \fBvolume_list\fP filter, if present.  Tags must be preceded
-by @ and are checked against all tags defined in the logical volume
-and volume group metadata for a match.
-@* is short-hand to check every tag set on the host machine (see
-\fBtags\fP above).
-Logical volume and volume groups can also be included in the list
-by name e.g. vg00, vg00/lvol1.
-.TP
-\fBmetadata\fP \(em Advanced metadata settings
-.IP
-\fBpvmetadatacopies\fP \(em When creating a physical volume using the
-LVM2 metadata format, this is the default number of copies of metadata
-to store on each physical volume.
-Currently it can be set to 0, 1 or 2.  The default is 1.
-If set to 2, one copy is placed at the beginning of the disk
-and the other is placed at the end.
-It can be overridden on the command line with \fB\-\-pvmetadatacopies\fP
-(see \fBpvcreate\fP).
-If creating a volume group with just one physical volume, it's a
-good idea to have 2 copies.  If creating a large volume group with
-many physical volumes, you may decide that 3 copies of the metadata
-is sufficient, i.e. setting it to 1 on three of the physical volumes,
-and 0 on the rest.  Every volume group must contain at least one
-physical volume with at least 1 copy of the metadata (unless using
-the text files described below).  The disadvantage of having lots
-of copies is that every time the tools access the volume group, every
-copy of the metadata has to be accessed, and this slows down the
-tools.
-.IP
-\fBpvmetadatasize\fP \(em Approximate number of sectors to set aside
-for each copy of the metadata. Volume groups with large numbers of
-physical or logical volumes, or volumes groups containing complex
-logical volume structures will need additional space for their metadata.
-The metadata areas are treated as circular buffers, so
-unused space becomes filled with an archive of the most recent
-previous versions of the metadata.
-.IP
-\fBpvmetadataignore\fP When creating a physical volume using the LVM2
-metadata format, this states whether metadata areas should be ignored.
-The default is "n".  If metadata areas on a physical volume are ignored,
-LVM will not not store metadata in the metadata areas present on newly
-created Physical Volumes.  The option can be overridden on the command
-line with \fB\-\-metadataignore\fP (See \fBpvcreate\fP and \fBpvchange\fP).
-Metadata areas cannot be created or extended after Logical Volumes have
-been allocated on the device.
-If you do not want to store metadata on this device, it is still wise
-always to allocate a metadata area (use a non-zero value for
-\fB\-\-pvmetadatacopies\fP) in case you need it in the future and to use
-this option to instruct LVM2 to ignore it.
-.IP
-\fBvgmetadatacopies\fP \(em When creating a volume group using the
-LVM2 metadata format, this is the default number of copies of metadata
-desired across all the physical volumes in the volume group.  If set to
-a non-zero value, LVM will automatically set or clear the metadataignore
-flag on the physical volumes (see \fBpvcreate\fP and \fBpvchange\fP
-\fB\-\-metadataignore\fP) in order to achieve the desired number of metadata
-copies.  An LVM command that adds or removes physical volumes (for example,
-\fBvgextend\fP, \fBvgreduce\fP, \fBvgsplit\fP, or \fBvgmerge\fP), may cause
-LVM to automatically set or clear the metadataignore flags.  Also, if
-physical volumes go missing or reappear, or a new number of copies is
-explicitly set (see \fBvgchange \-\-vgmetadatacopies\fP), LVM may adjust
-the metadataignore flags.
-Set \fBvgmetadatacopies\fP to 0 instructs LVM not to set or clear the
-metadataignore flags automatically.  You may set a value larger than the
-sum of all metadata areas on all physical volumes.  The value can
-be overridden on the command line with \fB\-\-vgmetadatacopies\fP for various
-commands (for example, \fBvgcreate\fP and \fBvgchange\fP), and can be
-queryied with the \fBvg_mda_copies\fP field of \fBvgs\fP.  This option
-is useful for volume groups containing large numbers of physical volumes
-with metadata as it may be used to minimize metadata read and write overhead.
-.IP
-\fBdirs\fP \(em List of directories holding live copies of LVM2
-metadata as text files.  These directories must not be on logical
-volumes.  It is possible to use LVM2 with a couple of directories
-here, preferably on different (non-logical-volume) filesystems
-and with no other on-disk metadata, \fBpvmetadatacopies = 0\fP.
-Alternatively these directories can be in addition to the
-on-disk metadata areas.  This feature was created during the
-development of the LVM2 metadata before the new on-disk metadata
-areas were designed and no longer gets tested.
-It is not supported under low-memory conditions, and it is
-important never to edit these metadata files unless you fully
-understand how things work: to make changes you should always use
-the tools as normal, or else vgcfgbackup, edit backup, vgcfgrestore.
+.B lvm dumpconfig \-\-type current
+
+Command to print all config settings that have been configured with a
+different value than the default (configured, non-default values are
+shown):
+.br
+.B lvm dumpconfig \-\-type diff
+
+Command to print a single config setting, with its default value,
+and a full description, where "Section" refers to the config section,
+e.g. global, and "Setting" refers to the name of the specific setting,
+e.g. umask:
+.br
+.B lvm dumpconfig \-\-type default --withfullcomments Section/Setting
+
+
 .SH FILES
 .I #DEFAULT_SYS_DIR#/lvm.conf
 .br
+.I #DEFAULT_SYS_DIR#/lvmlocal.conf
+.br
 .I #DEFAULT_ARCHIVE_DIR#
 .br
 .I #DEFAULT_BACKUP_DIR#
@@ -658,10 +204,10 @@ the tools as normal, or else vgcfgbackup, edit backup, vgcfgrestore.
 .I #DEFAULT_CACHE_DIR#/.cache
 .br
 .I #DEFAULT_LOCK_DIR#
+.br
+.I #DEFAULT_PROFILE_DIR#
+
 .SH SEE ALSO
-.BR lvm (8),
-.BR umask (2),
-.BR uname (2),
-.BR dlopen (3),
-.BR syslog (3),
-.BR syslog.conf (5)
+.BR lvm (8)
+.BR lvm-dumpconfig (8)
+


