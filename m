From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 20 Sep 2019 04:57:48 -0400
Subject: stable-2.02 - spec: Move blkdeactivate to device-mapper
Message-ID: <201909200857.x8K8vmtD024762@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6cad4eba9b8d59cfc78dcaab2fa13de1889367c6
Commit:        6cad4eba9b8d59cfc78dcaab2fa13de1889367c6
Parent:        44b98d77ecda701902c6c39b4c6ab7a09cfcce9b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Sep 20 10:55:29 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Sep 20 10:56:46 2019 +0200

spec: Move blkdeactivate to device-mapper

---
 spec/packages.inc |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index f7a9232..7330a5f 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -42,7 +42,6 @@ fi
 %defattr(-,root,root,-)
 %doc COPYING COPYING.LIB INSTALL README VERSION WHATS_NEW
 %doc doc/lvm_fault_handling.txt
-%{_sbindir}/blkdeactivate
 %{_sbindir}/fsadm
 %{_sbindir}/lvchange
 %{_sbindir}/lvconvert
@@ -100,7 +99,6 @@ fi
 %{_mandir}/man7/lvmsystemid.7.gz
 %{_mandir}/man7/lvmreport.7.gz
 %{_mandir}/man7/lvmraid.7.gz
-%{_mandir}/man8/blkdeactivate.8.gz
 %{_mandir}/man8/fsadm.8.gz
 %{_mandir}/man8/lvchange.8.gz
 %{_mandir}/man8/lvconvert.8.gz
@@ -537,8 +535,10 @@ for the kernel device-mapper.
 %files -n device-mapper
 %defattr(-,root,root,-)
 %doc COPYING COPYING.LIB WHATS_NEW_DM VERSION_DM README INSTALL
+%{_sbindir}/blkdeactivate
 %attr(755,root,root) %{_sbindir}/dmsetup
 %{_sbindir}/dmstats
+%{_mandir}/man8/blkdeactivate.8.gz
 %{_mandir}/man8/dmsetup.8.gz
 %{_mandir}/man8/dmstats.8.gz
 %if %{enable_dmfilemapd}


