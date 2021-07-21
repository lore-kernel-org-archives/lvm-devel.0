From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 21 Jul 2021 14:40:50 +0000 (GMT)
Subject: main - spec: Add vdoimport man page
Message-ID: <20210721144050.1C8B43858D34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=640fe5cf42fd136e60778513c5fc28499e78f9c2
Commit:        640fe5cf42fd136e60778513c5fc28499e78f9c2
Parent:        b70c341c9e9526cc21f590af73ccce2369755736
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jul 21 16:40:27 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jul 21 16:40:27 2021 +0200

spec: Add vdoimport man page

---
 spec/packages.inc | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index bf693a4ce..700e77506 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -61,6 +61,9 @@ fi
 %{_sbindir}/pvresize
 %{_sbindir}/pvs
 %{_sbindir}/pvscan
+%if %{have_with vdo}
+%{_sbindir}/vdoimport
+%endif
 %{_sbindir}/vgcfgbackup
 %{_sbindir}/vgcfgrestore
 %{_sbindir}/vgchange
@@ -70,7 +73,6 @@ fi
 %{_sbindir}/vgdisplay
 %{_sbindir}/vgexport
 %{_sbindir}/vgextend
-%{_sbindir}/vdoimport
 %{_sbindir}/vgimport
 %{_sbindir}/vgimportclone
 %{_sbindir}/vgimportdevices
@@ -123,6 +125,9 @@ fi
 %{_mandir}/man8/pvresize.8.gz
 %{_mandir}/man8/pvs.8.gz
 %{_mandir}/man8/pvscan.8.gz
+%if %{have_with vdo}
+%{_mandir}/man8/vdoimport.8.gz
+%endif
 %{_mandir}/man8/vgcfgbackup.8.gz
 %{_mandir}/man8/vgcfgrestore.8.gz
 %{_mandir}/man8/vgchange.8.gz


