From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 17 May 2018 05:06:02 -0400
Subject: master - Merge branch 'master' of git://sourceware.org/git/lvm2
Message-ID: <201805170906.w4H962RI015845@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7ee0a6e44d5e6c1085d04c407453f69ac14935b0
Commit:        7ee0a6e44d5e6c1085d04c407453f69ac14935b0
Parent:        3417d6229dcdcb2e1c9595026a8f97d10f25804a c6ca81a38d7012ec9d18a9ea00eff321ff2c47d0
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 17 09:52:57 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 17 09:52:57 2018 +0100

Merge branch 'master' of git://sourceware.org/git/lvm2


 lib/device/bcache.c                           |    9 ++++++---
 lib/label/label.c                             |    8 +++++++-
 lib/label/label.h                             |    1 +
 lib/metadata/cache_manip.c                    |    4 ++--
 lib/metadata/metadata-liblvm.c                |   13 +------------
 lib/metadata/metadata.c                       |    4 ++--
 lib/metadata/thin_manip.c                     |    2 +-
 test/shell/lvconvert-repair-mirror.sh         |    2 +-
 test/shell/lvextend-thin-metadata-dmeventd.sh |    4 ++--
 tools/toollib.c                               |    2 +-
 10 files changed, 24 insertions(+), 25 deletions(-)


