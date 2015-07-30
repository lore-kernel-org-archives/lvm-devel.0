From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 30 Jul 2015 18:40:15 +0000 (UTC)
Subject: master - spec: lockd_dlm requires dlm-lib instead of dlm
Message-ID: <20150730184015.89DA560D8A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bc90a25c26baa3d31f46415b3bb61e46f0477c1
Commit:        8bc90a25c26baa3d31f46415b3bb61e46f0477c1
Parent:        b40ccdd57cc0d57a71e584600c1025e649dc6d8a
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jul 30 20:19:35 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 30 20:39:38 2015 +0200

spec: lockd_dlm requires dlm-lib instead of dlm

---
 spec/packages.inc |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 33dda2e..2c0caa8 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -257,7 +257,7 @@ Summary: LVM locking daemon
 Group: System Environment/Base
 Requires: lvm2 = %{version}-%{release}
 %if %{enable_lockd_dlm}
-Requires: dlm >= %{dlm_version}
+Requires: dlm-lib >= %{dlm_version}
 %endif
 %if %{enable_lockd_sanlock}
 Requires: sanlock-lib >= %{sanlock_version}


