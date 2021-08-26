From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 26 Aug 2021 15:43:43 +0000 (GMT)
Subject: main - spec: Rename vdoimport to lvm_import_vdo.
Message-ID: <20210826154343.097D63858402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49822624e8b02bf108d79ac3ffd58a35c0c92c5e
Commit:        49822624e8b02bf108d79ac3ffd58a35c0c92c5e
Parent:        bbbd4fed69d88e67678994cb611d082d27bb774b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Aug 26 16:54:26 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Aug 26 17:14:08 2021 +0200

spec: Rename vdoimport to lvm_import_vdo.

---
 spec/packages.inc | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 700e77506..3f6e26d11 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -62,7 +62,7 @@ fi
 %{_sbindir}/pvs
 %{_sbindir}/pvscan
 %if %{have_with vdo}
-%{_sbindir}/vdoimport
+%{_sbindir}/lvm_import_vdo
 %endif
 %{_sbindir}/vgcfgbackup
 %{_sbindir}/vgcfgrestore
@@ -126,7 +126,7 @@ fi
 %{_mandir}/man8/pvs.8.gz
 %{_mandir}/man8/pvscan.8.gz
 %if %{have_with vdo}
-%{_mandir}/man8/vdoimport.8.gz
+%{_mandir}/man8/lvm_import_vdo.8.gz
 %endif
 %{_mandir}/man8/vgcfgbackup.8.gz
 %{_mandir}/man8/vgcfgrestore.8.gz


