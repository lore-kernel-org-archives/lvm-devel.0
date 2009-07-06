From: Mike Snitzer <snitzer@redhat.com>
Date: Sun,  5 Jul 2009 22:39:45 -0400
Subject: [PATCH v4 0/5] LVM2 topology support
Message-ID: <1246847990-13370-1-git-send-email-snitzer@redhat.com>
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
Fixed 'devices/data_alignment_detection' patch (5/5) to retrieve the
minimum_io_size and optimal_io_size for partitions from the parent
device's 'queue/'.  Both attributes are found in 'queue/'

v4 changes:
Added the md_chunk_alignment patch (1/1) to the patch series.
Simplified the _mda_setupi() change in --dataalignmentoffset patch (3/5).
Improved the documentation and comments in all patches. 

Mike Snitzer (5):
  Update 'md_chunk_alignment' to use stripe-width to align PV data
  cmdline: support for bytes and sectors
  Add --dataalignmentoffset to pvcreate to pad aligned data area
  Add devices/data_alignment_offset_detection to lvm.conf.
  Add devices/data_alignment_detection to lvm.conf.

 WHATS_NEW                        |    6 ++
 doc/example.conf                 |   23 +++++-
 lib/config/defaults.h            |    2 +
 lib/device/dev-md.c              |  161 ++++++++++++++++++++++++++++++++------
 lib/device/device.c              |  136 ++++++++++++++++++++++++++++++++
 lib/device/device.h              |   11 +++-
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   16 ++++-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   43 +++++++++-
 lib/metadata/metadata.h          |    1 +
 man/lvcreate.8.in                |    6 +-
 man/lvextend.8.in                |    4 +-
 man/lvm.conf.5.in                |   26 +++++-
 man/lvreduce.8.in                |    4 +-
 man/lvresize.8.in                |    4 +-
 man/pvcreate.8.in                |   20 ++++-
 man/vgchange.8.in                |    4 +-
 man/vgcreate.8.in                |    4 +-
 tools/args.h                     |    1 +
 tools/commands.h                 |   33 ++++----
 tools/lvmcmdline.c               |   20 ++++--
 tools/pvcreate.c                 |   23 +++++-
 tools/vgconvert.c                |    2 +-
 26 files changed, 473 insertions(+), 82 deletions(-)


