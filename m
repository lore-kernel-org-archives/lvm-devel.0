From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 4 May 2018 04:50:19 -0400
Subject: master - Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
Message-ID: <201805040850.w448oJVB030450@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bc50dc6e70453c98e45aaa845db2828e586f9370
Commit:        bc50dc6e70453c98e45aaa845db2828e586f9370
Parent:        ed837e6971ee84aa5b112e021df19901ae400216 f4a60fe00444bbb4aa54e32b0bef90a9c4eca704
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 4 09:49:55 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 4 09:49:55 2018 +0100

Merge branch 'master' of git+ssh://sourceware.org/git/lvm2


 daemons/clvmd/lvm-functions.c |    1 -
 lib/activate/activate.c       |   54 +++---
 lib/cache/lvmcache.c          |  378 ++++++++++++++++++++++++-----------------
 lib/cache/lvmcache.h          |   11 +-
 lib/commands/toolcontext.c    |   12 +-
 lib/commands/toolcontext.h    |    2 +-
 lib/metadata/metadata.c       |    4 +-
 lib/metadata/raid_manip.c     |   21 +--
 tools/toollib.c               |    4 +-
 9 files changed, 278 insertions(+), 209 deletions(-)


