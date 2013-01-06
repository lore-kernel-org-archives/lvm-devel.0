From: dongmao zhang <dmzhang@suse.com>
Date: Sun,  6 Jan 2013 16:46:34 +0800
Subject: [PATCH 0/2] let lvm2 support mirrored log in cluster evironment
Message-ID: <1357461996-368-1-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In cluster evironment, lvm2 does not support mirrored log for now.
This patch has changed cmirrord to a multi-threaded application
which makes it possible to create a CLUSTER mirror LV which has a mirrored log.

This make lvm2 support log type(core, disk, mirrored) both in local and cluster.


dongmao zhang (2):
  Change cmirrord to multi-thread
  support mirrored log in cluster evironment

 daemons/cmirrord/cluster.c   |   94 +++++++++++++++++++++++++++--------------
 daemons/cmirrord/functions.c |    6 +-
 daemons/cmirrord/local.c     |    3 +-
 lib/metadata/mirror.c        |   23 ----------
 lib/mirror/mirrored.c        |    4 +-
 tools/lvconvert.c            |    9 ----
 6 files changed, 70 insertions(+), 69 deletions(-)

-- 
1.7.3.4


