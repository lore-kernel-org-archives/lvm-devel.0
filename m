From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 08:05:41 -0400
Subject: master - Merge branch 'master' into 2018-04-30-vdo-support
Message-ID: <201805101205.w4AC5fRs032502@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2840b0ec1249a5c1890956ad42c6c617e240018
Commit:        d2840b0ec1249a5c1890956ad42c6c617e240018
Parent:        6abc3f10aea3e18a34e9bf1e5995ffa4cb496a5e bc50dc6e70453c98e45aaa845db2828e586f9370
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 4 13:32:07 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 4 13:32:07 2018 +0100

Merge branch 'master' into 2018-04-30-vdo-support


 WHATS_NEW                                |    1 +
 configure                                |   30 +---
 configure.ac                             |   21 +--
 daemons/clvmd/lvm-functions.c            |    1 -
 daemons/cmirrord/logging.h               |    1 -
 lib/Makefile.in                          |    1 +
 lib/activate/activate.c                  |   54 +++--
 lib/cache/lvmcache.c                     |  378 ++++++++++++++++++------------
 lib/cache/lvmcache.h                     |   11 +-
 lib/commands/toolcontext.c               |   14 +-
 lib/commands/toolcontext.h               |    2 +-
 lib/device/bcache-utils.c                |  229 ++++++++++++++++++
 lib/device/bcache.c                      |  158 +------------
 lib/device/bcache.h                      |   27 ++-
 lib/label/label.c                        |    2 +-
 lib/metadata/metadata.c                  |    4 +-
 lib/metadata/raid_manip.c                |   57 ++++--
 lib/misc/lib.h                           |    1 -
 make.tmpl.in                             |   20 ++-
 test/lib/aux.sh                          |    4 -
 test/shell/lvconvert-m-raid1-degraded.sh |   47 ++++
 test/unit/Makefile.in                    |    1 +
 test/unit/bcache_utils_t.c               |  352 ++++++++++++++++++++++++++++
 test/unit/matcher_t.c                    |   40 ++++
 test/unit/units.h                        |    2 +
 tools/tool.h                             |    1 -
 tools/toollib.c                          |    4 +-
 27 files changed, 1032 insertions(+), 431 deletions(-)


