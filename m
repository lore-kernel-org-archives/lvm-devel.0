From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 Sep 2016 14:52:57 +0000 (UTC)
Subject: master - rpm: install lvmreport.7
Message-ID: <20160912145257.1D1B660F42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bf1778e33b07a75aeb8a0f2d42737623e9e8699
Commit:        5bf1778e33b07a75aeb8a0f2d42737623e9e8699
Parent:        4ddcbe22b7f8004346a3b08ad09954f319baab2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 12 16:40:42 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 12 16:51:53 2016 +0200

rpm: install lvmreport.7

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index b74b3bd..41f6ff7 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -99,6 +99,7 @@ fi
 %endif
 %{_mandir}/man5/lvm.conf.5.gz
 %{_mandir}/man7/lvmsystemid.7.gz
+%{_mandir}/man7/lvmreport.7.gz
 %{_mandir}/man7/lvmraid.7.gz
 %{_mandir}/man8/blkdeactivate.8.gz
 %{_mandir}/man8/fsadm.8.gz


