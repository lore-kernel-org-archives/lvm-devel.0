From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 08:05:44 -0400
Subject: master - Merge branch 'master' into 2018-04-30-vdo-support
Message-ID: <201805101205.w4AC5i8q032529@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e649f710227a94258699399b02971e010b89b737
Commit:        e649f710227a94258699399b02971e010b89b737
Parent:        d2840b0ec1249a5c1890956ad42c6c617e240018 3600caa71def68d8f0b1389f0ee3b230ff1bfe56
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 10 12:34:04 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 10 12:34:04 2018 +0100

Merge branch 'master' into 2018-04-30-vdo-support


 doc/lvm-disk-reading.txt                           |  189 ++++++++++++++++++++
 lib/device/bcache-utils.c                          |   43 +++++
 lib/device/bcache.h                                |    1 +
 test/shell/component-raid.sh                       |    2 +-
 test/shell/lvconvert-raid-reshape-load.sh          |    2 +-
 .../lvconvert-raid-reshape-stripes-load-fail.sh    |    5 +-
 test/shell/lvconvert-raid-reshape-stripes-load.sh  |    2 +-
 test/unit/bcache_utils_t.c                         |   90 +++++++---
 8 files changed, 302 insertions(+), 32 deletions(-)


