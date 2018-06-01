From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 07:49:24 -0400
Subject: master - Merge branch 'master' into 2018-05-30-bcache-radix-tree
Message-ID: <201806011149.w51BnOrw027231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4d39d0f90e35c1f008f7e327902f622117fa8f9
Commit:        d4d39d0f90e35c1f008f7e327902f622117fa8f9
Parent:        7635df8cce131b07b45024e690e4e6917cceb198 6d14d5d16b92c520b5f4ee464f171684cac40735
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 31 16:36:04 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 31 16:36:04 2018 +0100

Merge branch 'master' into 2018-05-30-bcache-radix-tree


 lib/device/dev-cache.c          |  187 +++++++++++++++++++++++++++++++++------
 lib/device/dev-cache.h          |    2 +
 lib/filters/filter-persistent.c |   10 ++-
 lib/label/label.c               |   65 +++++++++++---
 4 files changed, 219 insertions(+), 45 deletions(-)


