From: Mike Snitzer <snitzer@redhat.com>
Date: Sat, 25 Jul 2009 18:14:50 -0400
Subject: [PATCH 0/6 v7] LVM2 topology support
Message-ID: <1248560096-28641-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

LVM2 topology support to properly align the PV's pe_start using the
associated 'alignment_offset' exposed in sysfs.

Provides manual configuration with pvcreate --dataalignmentoffset and
auto config control via 'devices/data_alignment_offset_detection' in
lvm.conf.

Documentation was added to the lvm.conf and pvcreate man pages.

v2 changes:
Also added another method for auto detection of --dataalignment using
the topology information that is exposed in sysfs.  Controlled via
'devices/data_alignment_detection' in lvm2.conf.

v3 changes:
Fixed 'devices/data_alignment_detection' patch (3/6) to retrieve the
minimum_io_size and optimal_io_size for partitions from the parent
device's 'queue/'.  Both attributes are found in 'queue/'

v4 changes:
Simplified the _mda_setup() change in --dataalignmentoffset patch (1/6).
Improved the documentation and comments in all patches. 

v5 changes:
Improved LVM2's support for partitions (in the MD and topology code paths).
Added MD, partitions, and topology tests to the testsuite.

v6 changes:
Added pe_align_offset to 'struct physical_volume'; Added
set_pe_align_offset().  After pe_start is initialized pe_align_offset is
added to it.

v7 changes:
Revised pvcreate manpage to document --datalignmentoffset more clearly.
Added negative check that makes sure the PV's data area is not beyond
the end of the device.


