From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 16 Mar 2017 06:47:16 -0400
Subject: master - spec: lvmchange is built-in command
Message-ID: <201703161047.v2GAlGbi030471@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fd5c8e908cbb18885d3ddd6ae0e9a3ce5a476d5
Commit:        2fd5c8e908cbb18885d3ddd6ae0e9a3ce5a476d5
Parent:        affe055462abde154a31eea0aa1775157c35bdcd
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Mar 16 11:44:10 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Mar 16 11:44:10 2017 +0100

spec: lvmchange is built-in command

---
 spec/packages.inc |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 85c9e6d..d3a9e88 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -50,7 +50,6 @@ fi
 %{_sbindir}/lvdisplay
 %{_sbindir}/lvextend
 %{_sbindir}/lvm
-%{_sbindir}/lvmchange
 %{_sbindir}/lvmconf
 %{_sbindir}/lvmconfig
 %{_sbindir}/lvmdiskscan
@@ -112,7 +111,6 @@ fi
 %{_mandir}/man8/lvm-dumpconfig.8.gz
 %{_mandir}/man8/lvm.8.gz
 %{_mandir}/man8/lvm2-activation-generator.8.gz
-%{_mandir}/man8/lvmchange.8.gz
 %{_mandir}/man8/lvmconf.8.gz
 %{_mandir}/man8/lvmconfig.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz


