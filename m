From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 19 Jun 2009 18:55:04 -0400
Subject: [PATCH v2 0/4] LVM2 topology support
Message-ID: <1245452108-25318-1-git-send-email-snitzer@redhat.com>
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


Also added another method for auto detection of --dataalignment using
the topology information that is exposed in sysfs.  Controlled via
'devices/data_alignment_detection' in lvm2.conf.


Mike Snitzer (4):
  cmdline: support for bytes and sectors
  pvcreate: --dataalignmentoffset
  Add devices/data_alignment_offset_detection to lvm.conf.
  Add devices/data_alignment_detection to lvm.conf.

 WHATS_NEW                        |    5 ++
 doc/example.conf                 |   19 ++++++-
 lib/config/defaults.h            |    2 +
 lib/device/device.c              |   98 ++++++++++++++++++++++++++++++++++++++
 lib/device/device.h              |    9 ++++
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   24 ++++++++-
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   36 +++++++++++++-
 lib/metadata/metadata.h          |    1 +
 man/lvcreate.8.in                |    6 +-
 man/lvextend.8.in                |    4 +-
 man/lvm.conf.5.in                |   22 +++++++-
 man/lvreduce.8.in                |    4 +-
 man/lvresize.8.in                |    4 +-
 man/pvcreate.8.in                |   18 ++++++-
 man/vgchange.8.in                |    4 +-
 man/vgcreate.8.in                |    4 +-
 tools/args.h                     |    1 +
 tools/commands.h                 |   33 +++++++------
 tools/lvmcmdline.c               |   20 +++++--
 tools/pvcreate.c                 |   23 ++++++++-
 tools/vgconvert.c                |    2 +-
 25 files changed, 292 insertions(+), 52 deletions(-)


