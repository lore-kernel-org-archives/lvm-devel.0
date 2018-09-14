From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 14 Sep 2018 08:08:05 -0400
Subject: master - spec: Remove lvmconf refernces
Message-ID: <201809141208.w8EC85FQ003939@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ccb08dfa1d6828c494882030ef181d7fdf38cb0b
Commit:        ccb08dfa1d6828c494882030ef181d7fdf38cb0b
Parent:        19a59cc53c723f3614d68edcdd9dfabe15c1299b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Sep 14 13:49:51 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Sep 14 13:49:51 2018 +0200

spec: Remove lvmconf refernces

Fixes: 81ca0cb1619b6ea22fa68f54783cd62dafbd2eaf
---
 spec/packages.inc |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 4049f27..67a521d 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -41,7 +41,6 @@ fi
 %{_sbindir}/lvdisplay
 %{_sbindir}/lvextend
 %{_sbindir}/lvm
-%{_sbindir}/lvmconf
 %{_sbindir}/lvmconfig
 %{_sbindir}/lvmdiskscan
 %{_sbindir}/lvmdump
@@ -99,7 +98,6 @@ fi
 %{_mandir}/man8/lvm-dumpconfig.8.gz
 %{_mandir}/man8/lvm.8.gz
 %{_mandir}/man8/lvm2-activation-generator.8.gz
-%{_mandir}/man8/lvmconf.8.gz
 %{_mandir}/man8/lvmconfig.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
 %{_mandir}/man8/lvmdump.8.gz


