From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 13 Jul 2009 16:11:16 -0400
Subject: [PATCH 0/6 v5] LVM2 topology support
Message-ID: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
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

Testing with pvcreate + vgextend + vgreduce + vgextend + vgreduce ...
proved to maintain the pe_start from the initial pvcreate.

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

Mike Snitzer (6):
  Add --dataalignmentoffset to pvcreate to pad aligned data area
  Add devices/data_alignment_offset_detection to lvm.conf.
  Add devices/data_alignment_detection to lvm.conf.
  Improve ability to lookup primary device associated with partition
  Retrieve MD sysfs attributes for MD partitions
  Add MD, partition and topology tests to the LVM2 test-suite

 WHATS_NEW                        |    3 +
 doc/example.conf                 |   21 ++++-
 lib/config/defaults.h            |    2 +
 lib/device/dev-md.c              |   13 ++-
 lib/device/device.c              |  184 ++++++++++++++++++++++++++++++++++++++
 lib/device/device.h              |   12 +++
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   16 +++-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   37 +++++++-
 lib/metadata/metadata.h          |    1 +
 man/lvm.conf.5.in                |   22 ++++-
 man/pvcreate.8.in                |   20 ++++-
 test/t-pvcreate-operation-md.sh  |   85 +++++++++++++++++
 test/t-pvcreate-usage.sh         |   12 +++
 test/test-utils.sh               |    2 +-
 tools/args.h                     |    1 +
 tools/commands.h                 |    7 +-
 tools/pvcreate.c                 |   23 +++++-
 tools/vgconvert.c                |    2 +-
 22 files changed, 444 insertions(+), 24 deletions(-)
 create mode 100644 test/t-pvcreate-operation-md.sh


