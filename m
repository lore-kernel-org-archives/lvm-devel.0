From: Sergei Shtepa <sergei.shtepa@veeam.com>
Date: Thu, 28 Jan 2021 20:15:17 +0300
Subject: [PATCH 0/1] lvm2: blk_interposer and new dm remap functionality
Message-ID: <1611854118-32204-1-git-send-email-sergei.shtepa@veeam.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

Now we can connect any dm-target to a device with an
already mounted file system.

For the dm-linear device creation command, the `noexcl` parameter
has been added, which allows to open block devices without
FMODE_EXCL mode. It allows to create a dm-linear device on a block
device with an already mounted file system.
The new ioctl DM_DEV_REMAP allows to redirect bio requests
from any block device to any dm device.

"dmsetup remap start my-dm-linear /dev/sda1" command
switches all requests to the /dev/sda1 device to my-dm-linear.

"dmsetup remap finish my-dm-linear" command disables
the interception of requests.

Synchronous changes to the linux project were in another email.

Sergei Shtepa (1):
  add dm remap functionality.

 device_mapper/all.h                 |  6 +-
 device_mapper/ioctl/libdm-iface.c   | 99 ++++++++++++++++++++++++-----
 device_mapper/ioctl/libdm-targets.h |  2 +
 device_mapper/libdm-common.c        | 10 +--
 device_mapper/misc/dm-ioctl.h       | 16 ++++-
 libdm/.exported_symbols.Base        |  2 +
 libdm/dm-tools/dmsetup.c            | 63 ++++++++++++++++--
 libdm/ioctl/libdm-iface.c           | 91 +++++++++++++++++++++-----
 libdm/ioctl/libdm-targets.h         |  2 +
 libdm/libdevmapper.h                | 12 ++--
 libdm/libdm-common.c                | 10 +--
 libdm/misc/dm-ioctl.h               | 16 ++++-
 12 files changed, 276 insertions(+), 53 deletions(-)

-- 
2.20.1


