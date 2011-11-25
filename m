From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Nov 2011 10:59:02 +0100
Subject: [PATCH 0/7] Reduce system calls
Message-ID: <cover.1322213495.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Seems like over the time we have added lots of system calls
which are not fully using the device cache or the code is 
just distrustful too much.

This patch set tries to reduce the number of system calls
and should have some positive impact on RHZB 744926.

In my measurements it seems like it's giving extra 10%-30% speedup
of processing commands like lvcreate with larger set of devices in system.
(depends on the lvm.conf configuration as well.)

!!! NOTICE !!!

It's worth to note that our current code for obtaining device list from
udev is upto 80% slower that our normal scan (yep, udev is quite slow and
does about ~8 syscalls per device) so unless we try to extend this udev 
scan with just check only for real PV devices (which has been reject)
we have quite noticable speed regression when larger set of devices
is present in the system.

Patch set should be back-portable.

Careful review for '*' please.

Zdenek Kabelac (7):
  Add common initialization code for struct device
* Add caching of BLKGETSIZE64 ioctl
* Do not drop cache  block_size for cached device.
* Do not lstat common path prefix
  Minor cleanup of strchr analyzer warning
* Drop extra stat before open of device
  Skip double stat() call with each _insert

 lib/device/dev-cache.c |  103 +++++++++++++++++++++++++++---------------------
 lib/device/dev-io.c    |   39 +++++++-----------
 lib/device/device.h    |    1 +
 3 files changed, 75 insertions(+), 68 deletions(-)

--
1.7.7.3


