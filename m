From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:18 +0000 (UTC)
Subject: master - spec: Package the new clvmd/cmirrord systemd units.
Message-ID: <20140228102618.8622E60F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=244b80d948052c07b6f252c40146bae4a866362c
Commit:        244b80d948052c07b6f252c40146bae4a866362c
Parent:        9770c03ce0e7a955a6c6a4f7921ccdaf9c3bb1f0
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Thu Feb 20 09:49:45 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:52 2014 +0100

spec: Package the new clvmd/cmirrord systemd units.

---
 spec/packages.inc |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 4c00617..d7502de 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -259,6 +259,11 @@ fi
 %attr(755,root,root) /usr/sbin/clvmd
 %{_mandir}/man8/clvmd.8.gz
 %{_sysconfdir}/rc.d/init.d/clvmd
+%if %{enable_systemd}
+  %{_unitdir}/lvm2-clvmd.service
+  %{_unitdir}/lvm2-cluster-activation.service
+  %{_unitdir}/../lvm2-cluster-activation
+%endif
 
 %endif
 
@@ -291,6 +296,9 @@ fi
 %attr(755,root,root) /usr/sbin/cmirrord
 %{_mandir}/man8/cmirrord.8.gz
 %{_sysconfdir}/rc.d/init.d/cmirrord
+%if %{enable_systemd}
+  %{_unitdir}/lvm2-cmirrord.service
+%endif
 
 %endif
 


