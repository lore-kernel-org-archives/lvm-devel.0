From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 23 May 2018 07:49:23 -0400
Subject: master - Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
Message-ID: <201805231149.w4NBnNLT001474@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=87291a28328e6b786ea6674aa52003e7f4af0ac3
Commit:        87291a28328e6b786ea6674aa52003e7f4af0ac3
Parent:        a60416a13fbfdf053c327709c9997239f2ec1c71 61583281e5703f8b923654d0ff1576d6093d2ead
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 23 09:14:29 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 23 09:14:29 2018 +0100

Merge branch 'master' of git+ssh://sourceware.org/git/lvm2


 lib/cache/lvmcache.c                     |  125 ++++++++++++++++++++++++++----
 lib/cache/lvmcache.h                     |    2 +
 lib/cache/lvmetad.c                      |    2 +
 lib/device/device.h                      |    1 +
 lib/filters/filter-md.c                  |   89 +++++++++++++++++++---
 test/shell/process-each-duplicate-pvs.sh |   22 +++---
 test/shell/pv-duplicate-uuid.sh          |    5 +-
 7 files changed, 204 insertions(+), 42 deletions(-)


