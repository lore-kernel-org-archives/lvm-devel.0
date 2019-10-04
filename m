From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 4 Oct 2019 10:33:10 -0400
Subject: stable-2.02 - spec: Fix lvm2-activation-generator man page handling
Message-ID: <201910041433.x94EXAUc026728@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=219c4c2ce2c605960ad760ac99be27b2665a8c43
Commit:        219c4c2ce2c605960ad760ac99be27b2665a8c43
Parent:        45ee63ede955d3188119d039faca26a159038f67
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Oct 4 16:29:38 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Oct 4 16:32:52 2019 +0200

spec: Fix lvm2-activation-generator man page handling

lvm2-activation-generator is not installed when systemd is not in the
system.

(cherry picked from commit b20b23dfc6bef6f0e468f8331b277e974d1fea12)

Conflicts:
	spec/packages.inc
---
 spec/packages.inc |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 7330a5f..14fc02c 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -108,7 +108,9 @@ fi
 %{_mandir}/man8/lvm-config.8.gz
 %{_mandir}/man8/lvm-dumpconfig.8.gz
 %{_mandir}/man8/lvm.8.gz
-%{_mandir}/man8/lvm2-activation-generator.8.gz
+%if %{enable_systemd}
+ %{_mandir}/man8/lvm2-activation-generator.8.gz
+%endif
 %{_mandir}/man8/lvmconf.8.gz
 %{_mandir}/man8/lvmconfig.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz


