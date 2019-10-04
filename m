From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 4 Oct 2019 10:31:41 -0400
Subject: master - spec: Fix lvm2-activation-generator man page handling
Message-ID: <201910041431.x94EVfKv026698@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b20b23dfc6bef6f0e468f8331b277e974d1fea12
Commit:        b20b23dfc6bef6f0e468f8331b277e974d1fea12
Parent:        d69304114948451c72b399346194af6ed4e10f9c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Oct 4 16:29:38 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Oct 4 16:29:38 2019 +0200

spec: Fix lvm2-activation-generator man page handling

lvm2-activation-generator is not installed when systemd is not in the
system.
---
 spec/packages.inc |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index cbddbd5..c0d3793 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -95,7 +95,9 @@ fi
 %{_mandir}/man8/lvm-config.8.gz
 %{_mandir}/man8/lvm-dumpconfig.8.gz
 %{_mandir}/man8/lvm.8.gz
-%{_mandir}/man8/lvm2-activation-generator.8.gz
+%if %{enable_systemd}
+ %{_mandir}/man8/lvm2-activation-generator.8.gz
+%endif
 %{_mandir}/man8/lvmconfig.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
 %{_mandir}/man8/lvmdump.8.gz


