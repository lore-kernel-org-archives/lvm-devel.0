From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 04:45:54 -0400
Subject: master - Merge branch '2018-06-05-remove-applib'
Message-ID: <201806080845.w588jsBk003377@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b67ef90438052d3e01f563cdd25e2268f4e02c20
Commit:        b67ef90438052d3e01f563cdd25e2268f4e02c20
Parent:        cc87f55e256dec59e326163c66c50565b2521659 0d22b58172808f050abeacdb5d6a7b7132b91a8c
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 09:42:22 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 09:42:22 2018 +0100

Merge branch '2018-06-05-remove-applib'


 Makefile.in              |   21 +-
 aclocal.m4               |   91 ++-
 configure                | 1996 +---------------------------------------------
 configure.ac             |   63 +--
 include/configure.h.in   |   66 +--
 liblvm/Doxyfile          |  254 ------
 liblvm/Makefile.in       |   81 --
 liblvm/liblvm2app.pc.in  |   11 -
 liblvm/lvm2app.h         | 1983 ---------------------------------------------
 liblvm/lvm_base.c        |  216 -----
 liblvm/lvm_lv.c          |  820 -------------------
 liblvm/lvm_misc.c        |  168 ----
 liblvm/lvm_misc.h        |   46 --
 liblvm/lvm_prop.c        |   74 --
 liblvm/lvm_prop.h        |   49 --
 liblvm/lvm_prop_fields.h |   22 -
 liblvm/lvm_pv.c          |  474 -----------
 liblvm/lvm_vg.c          |  564 -------------
 liblvm/test/vgadd.c      |   90 ---
 liblvm/test/vgshow.c     |   95 ---
 test/api/Makefile.in     |   33 -
 test/api/lvtest.c        |   64 --
 test/api/pe_start.c      |   47 --
 test/api/percent.c       |   63 --
 test/api/test.c          | 1110 --------------------------
 test/api/thin_percent.c  |   78 --
 test/api/vglist.c        |   73 --
 test/api/vgtest.c        |  164 ----
 28 files changed, 108 insertions(+), 8708 deletions(-)


