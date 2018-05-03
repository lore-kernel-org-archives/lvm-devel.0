From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 3 May 2018 15:17:53 -0400
Subject: master - Merge branch '2018-05-03-improve-bcache-utils'
Message-ID: <201805031917.w43JHr6n012495@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49db9b5e0b35f6b0a47ad10276fb252c09f438ef
Commit:        49db9b5e0b35f6b0a47ad10276fb252c09f438ef
Parent:        4ebfd8e8eb68442efc334b35bc1f22eda3e4dd3d ac18164a525aedcee9f55deff9a0a77528bfd0e8
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 3 20:15:13 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 3 20:15:13 2018 +0100

Merge branch '2018-05-03-improve-bcache-utils'


 lib/Makefile.in            |    1 +
 lib/device/bcache-utils.c  |  229 ++++++++++++++++++++++++++++
 lib/device/bcache.c        |  150 +------------------
 lib/device/bcache.h        |   23 ++--
 lib/label/label.c          |    2 +-
 test/unit/Makefile.in      |    1 +
 test/unit/bcache_utils_t.c |  352 ++++++++++++++++++++++++++++++++++++++++++++
 test/unit/units.h          |    2 +
 8 files changed, 603 insertions(+), 157 deletions(-)


