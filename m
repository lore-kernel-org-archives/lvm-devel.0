From: dongmao zhang <dmzhang@suse.com>
Date: Thu, 26 Sep 2013 18:53:27 +0800
Subject: [PATCH 0/4] LVM/cmirrord support write improvement.
Message-ID: <cover.1380191958.git.dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These patches work with dm-log-userspace enhancement.
LVM, device-mapper and cmirrord begin to support
merging mark/flush request and delaying the clear
request. This would increase the write throughput
of cluster raid1 based on my own test.

dongmao zhang (4):
  cmirrord add support_delay_clear option
  cmirrord create new function _clog_flush
  add support_delay_flush to device-mapper
  cluster LVM use flag DM_SUPPORT_DELAY_FLUSH

 daemons/cmirrord/functions.c |   60 ++++++++++++++++++++++++++++++++---------
 lib/mirror/mirrored.c        |    4 +++
 libdm/libdevmapper.h         |    3 ++
 libdm/libdm-deptree.c        |    8 +++++
 4 files changed, 62 insertions(+), 13 deletions(-)

-- 
1.7.3.4


