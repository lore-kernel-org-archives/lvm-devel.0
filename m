From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 30 Jul 2009 19:07:14 -0400
Subject: [PATCH 0/5] LVM2 topology autodetect support (patchset 2)
Message-ID: <1248995239-19128-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the second LVM2 topology patchset; it adds the ability to
autodetect Linux's I/O topology attributes that are associated with a
device.

It should be noted that the changes to lib/device/device.c were the
basis for the upstream libblkid's topology support.  Moving forward we
may look to use libblkid directly but the topology-aware libblkkid isn't
yet available upstream.

Mike Snitzer (5):
  Add devices/data_alignment_offset_detection to lvm.conf.
  Add devices/data_alignment_detection to lvm.conf.
  Improve ability to lookup primary device associated with partition.
  Retrieve MD sysfs attributes for MD partitions.
  Add MD, partition and topology tests to the LVM2 test-suite.

 WHATS_NEW                       |    2 +
 doc/example.conf                |   21 ++++-
 lib/config/defaults.h           |    2 +
 lib/device/dev-md.c             |   13 ++-
 lib/device/device.c             |  193 +++++++++++++++++++++++++++++++++++++++
 lib/device/device.h             |   12 +++
 lib/format_text/format-text.c   |    6 +-
 lib/metadata/metadata.c         |   27 ++++++
 man/lvm.conf.5.in               |   22 ++++-
 test/t-pvcreate-operation-md.sh |   91 ++++++++++++++++++
 test/t-pvcreate-usage.sh        |   12 +++
 test/test-utils.sh              |    2 +-
 12 files changed, 392 insertions(+), 11 deletions(-)
 create mode 100644 test/t-pvcreate-operation-md.sh


