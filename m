From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 07:49:29 -0400
Subject: master - Merge branch '2018-05-30-bcache-radix-tree'
Message-ID: <201806011149.w51BnTYP027245@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb379c86c4b468858b781695934d5ad5957108d2
Commit:        cb379c86c4b468858b781695934d5ad5957108d2
Parent:        81f07c3cca417bbf8d290073a20586b47a6d127e d4d39d0f90e35c1f008f7e327902f622117fa8f9
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 1 12:45:33 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 1 12:45:33 2018 +0100

Merge branch '2018-05-30-bcache-radix-tree'


 lib/Makefile.in     |    1 +
 lib/device/bcache.c |  212 ++++++++++++++++++++++++++++-----------------------
 make.tmpl.in        |    2 +-
 3 files changed, 117 insertions(+), 98 deletions(-)


