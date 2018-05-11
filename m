From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 11 May 2018 00:41:05 -0400
Subject: master - Merge branch 'master' of git+ssh://sourceware.org/git/lvm2
Message-ID: <201805110441.w4B4f5s9022246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b02b35c3eef04ddc62302328323d7874f6b9daa
Commit:        3b02b35c3eef04ddc62302328323d7874f6b9daa
Parent:        5f780813f295cd927d92d669ab086063adb1534e 9ad42e5f068ec9c712724631696afb9eb96bc24b
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 11 05:39:27 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 11 05:39:27 2018 +0100

Merge branch 'master' of git+ssh://sourceware.org/git/lvm2


 lib/cache/lvmcache.c             |    2 +-
 lib/cache/lvmetad.c              |    2 +-
 lib/commands/toolcontext.c       |    2 +-
 lib/commands/toolcontext.h       |    1 +
 lib/device/dev-cache.c           |   70 +++++++++++++++++++++++++++++-----
 lib/device/dev-io.c              |    4 +-
 lib/device/dev-luks.c            |   13 ++----
 lib/device/dev-md.c              |   67 +++++++++++++++++++++++++--------
 lib/device/dev-swap.c            |   16 ++-----
 lib/device/dev-type.c            |   18 +++------
 lib/device/dev-type.h            |    7 ++-
 lib/device/device.h              |    2 +
 lib/filters/filter-composite.c   |    9 +++-
 lib/filters/filter-md.c          |   39 ++++++++++++++++--
 lib/filters/filter-partitioned.c |   12 +++++-
 lib/filters/filter-persistent.c  |   78 ++++++++++++++++++++++++++++++-------
 lib/filters/filter-signature.c   |   12 +++---
 lib/filters/filter-usable.c      |    9 ----
 lib/filters/filter.h             |    2 +-
 lib/label/label.c                |   58 +++++++++++++++++++++++-----
 lib/label/label.h                |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |   19 ++-------
 lib/metadata/mirror.c            |    9 ++--
 tools/lvmdiskscan.c              |    5 +-
 tools/pvck.c                     |   48 +++++++++++++++++------
 tools/pvcreate.c                 |    3 +
 tools/pvscan.c                   |   49 ++++++++++++++++++++---
 tools/vgcreate.c                 |    3 +
 tools/vgextend.c                 |    3 +
 30 files changed, 408 insertions(+), 158 deletions(-)


