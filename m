From: Mike Snitzer <snitzer@redhat.com>
Date: Tue,  9 Jun 2009 00:42:13 -0400
Subject: [PATCH 0/3] LVM2 topology support
In-Reply-To: <1244522536-2132-1-git-send-email-snitzer@redhat.com>
References: <1244522536-2132-1-git-send-email-snitzer@redhat.com>
Message-ID: <1244522536-2132-2-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

pvcreate --dataalignmentoffset support and configuration via
devices/data_alignment_offset_detection.

Documentation was added to the lvm.conf and pvcreate man pages.

Testing with pvcreate + vgextend + vgreduce + vgextend + vgreduce ...
proved to maintain the pe_start from the original pvcreate.

Mike Snitzer (3):
  cmdline: support for bytes and sectors
  pvcreate: --dataalignmentoffset
  Add devices/data_alignment_offset_detection to lvm.conf.

 WHATS_NEW                        |    3 ++
 doc/example.conf                 |    5 +++
 lib/config/defaults.h            |    1 +
 lib/device/device.c              |   60 ++++++++++++++++++++++++++++++++++++++
 lib/device/device.h              |    3 ++
 lib/format1/format1.c            |    1 +
 lib/format_pool/format_pool.c    |    1 +
 lib/format_text/archiver.c       |    2 +-
 lib/format_text/format-text.c    |   33 +++++++++++++++++++--
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   10 +++++-
 lib/metadata/metadata.h          |    1 +
 man/lvm.conf.5.in                |    8 ++++-
 man/pvcreate.8.in                |   18 ++++++++++-
 tools/args.h                     |    1 +
 tools/commands.h                 |   33 +++++++++++----------
 tools/lvmcmdline.c               |   20 +++++++++----
 tools/pvcreate.c                 |   23 +++++++++++++-
 tools/vgconvert.c                |    2 +-
 19 files changed, 192 insertions(+), 34 deletions(-)


