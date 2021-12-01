From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed,  1 Dec 2021 14:37:28 +0000 (GMT)
Subject: main - spec: Add lvmautoactivation man page
Message-ID: <20211201143728.3C57F3858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36095ac374edeccd256bf565aa66d629ad5480c3
Commit:        36095ac374edeccd256bf565aa66d629ad5480c3
Parent:        470b967bc5a66b3b066af5694a10220be7a2a155
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Dec 1 15:35:40 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Dec 1 15:36:34 2021 +0100

spec: Add lvmautoactivation man page

---
 spec/packages.inc | 1 +
 1 file changed, 1 insertion(+)

diff --git a/spec/packages.inc b/spec/packages.inc
index 74d795520..9b4eba263 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -88,6 +88,7 @@ fi
  %{_sbindir}/lvmpolld
 %endif
 %{_mandir}/man5/lvm.conf.5.gz
+%{_mandir}/man7/lvmautoactivation.7.gz
 %{_mandir}/man7/lvmsystemid.7.gz
 %{_mandir}/man7/lvmreport.7.gz
 %{_mandir}/man7/lvmraid.7.gz


