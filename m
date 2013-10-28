From: dongmao zhang <dmzhang@suse.com>
Date: Mon, 28 Oct 2013 18:17:32 +0800
Subject: [PATCH 0/2] cmirror patch to improve cluster raid1 performance[v3]
In-Reply-To: <yes>
References: <yes>
Message-ID: <cover.1382955203.git.dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These patches work with dm-log-userspace enhancement.
LVM, device-mapper and cmirrord begin to support
merging mark/flush request(if DM_INTEGRATED_FLUSH is set)
This would increase the write throughput of cluster raid1 
based on my own test.


dongmao zhang (2):
  add integrated_flush support to device-mapper
  cmirrord support DM_INTEGRATED_FLUSH

 daemons/cmirrord/functions.c |   62 +++++++++++++++++++++++++++++++++---------
 daemons/cmirrord/local.c     |    9 +++++-
 lib/mirror/mirrored.c        |    4 +++
 libdm/libdevmapper.h         |    3 ++
 libdm/libdm-deptree.c        |    8 +++++
 5 files changed, 72 insertions(+), 14 deletions(-)

-- 
1.7.3.4


