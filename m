From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 14:19:57 -0400
Subject: master - Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
Message-ID: <201806011819.w51IJvnW003834@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4d19321fd36fd6bf3f6170363f51be9ab39c03a7
Commit:        4d19321fd36fd6bf3f6170363f51be9ab39c03a7
Parent:        02c4901d893a1b833260a7cbb66b9ad285d7ce39 7b5b1a9b6f03e9452c7a9d602247e61e808c316b
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 1 19:19:11 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 1 19:19:11 2018 +0100

Merge branch 'master' of git+ssh://sourceware.org/git/lvm2


 lib/cache/lvmcache.c      |    6 ++++--
 lib/cache/lvmetad.c       |    6 +++---
 lib/label/label.c         |    2 +-
 lib/locking/lvmlockd.c    |   12 ++++++------
 lib/metadata/lv_manip.c   |    2 +-
 lib/metadata/metadata.c   |   26 ++++++++++++++------------
 lib/metadata/mirror.c     |    2 +-
 lib/metadata/raid_manip.c |    2 +-
 lib/metadata/vg.c         |    2 +-
 tools/lvconvert.c         |   14 +++++++-------
 tools/lvcreate.c          |    4 ++--
 tools/pvmove.c            |    2 +-
 tools/pvscan.c            |    2 +-
 tools/vgchange.c          |    2 +-
 tools/vgcreate.c          |    2 +-
 tools/vgexport.c          |    2 +-
 tools/vgimport.c          |    2 +-
 tools/vgmerge.c           |    2 +-
 tools/vgsplit.c           |    2 +-
 19 files changed, 49 insertions(+), 45 deletions(-)


