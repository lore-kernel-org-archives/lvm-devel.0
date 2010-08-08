From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:37:35 +0200
Subject: [PATCH 0/2] Fix leak reports
Message-ID: <cover.1281256324.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Two small patches trying to fix shown leaks by internal tracing.

1st patch triest to swap order of pool destroy and check for leaks
  in lvm2_exit() routine.

2nd patch fixes uncleaned resource in error path 
  (visible in t-lvm-init.sh test)

Zdenek Kabelac (2):
  Fix report of leak of _mem_pool in lvm2_exit()
  Fix report of uninitalized pool leak  (t-lvm-init.sh)

 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c |    4 ++--
 tools/lvmcmdline.c                           |    4 ++++
 2 files changed, 6 insertions(+), 2 deletions(-)

-- 
1.7.2.1


