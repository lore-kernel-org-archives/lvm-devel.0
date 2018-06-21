From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 21 Jun 2018 12:12:53 -0400
Subject: master - Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
Message-ID: <201806211612.w5LGCrvJ026914@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=18528180d9f588e265747f4710a8767756454b4c
Commit:        18528180d9f588e265747f4710a8767756454b4c
Parent:        72e2e92f4c23b75efdf08ee5a4019b6beb86b9f1 dd7ebec12028a65081f676b5f52215b012c75c88
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu Jun 21 17:12:09 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu Jun 21 17:12:09 2018 +0100

Merge branch 'master' of git+ssh://sourceware.org/git/lvm2


 lib/commands/toolcontext.c      |   18 ---------
 lib/config/config_settings.h    |    2 +-
 lib/device/dev-cache.c          |   80 +++------------------------------------
 lib/device/dev-cache.h          |    2 -
 lib/filters/filter-persistent.c |    7 ++-
 lib/metadata/mirror.c           |    2 +-
 6 files changed, 13 insertions(+), 98 deletions(-)


