From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 30 Apr 2015 04:35:44 +0000 (UTC)
Subject: master - spec: Pull in lvmconfig and associated manpages.
Message-ID: <20150430043544.D057F60D5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13fea879606c4dfdeb8d7686ca2ab606a70a5cd4
Commit:        13fea879606c4dfdeb8d7686ca2ab606a70a5cd4
Parent:        d6b624686478c0f162ac4f7f4af7d35d5539d151
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 29 17:58:19 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Apr 30 06:35:05 2015 +0200

spec: Pull in lvmconfig and associated manpages.

---
 spec/packages.inc |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 6d6f92e..109abd2 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -77,6 +77,7 @@ fi
 %{_sbindir}/vgs
 %{_sbindir}/vgscan
 %{_sbindir}/vgsplit
+%{_sbindir}/lvmconfig
 %{_sbindir}/lvmconf
 %{_sbindir}/blkdeactivate
 %if %{have_service lvmetad}
@@ -139,6 +140,8 @@ fi
 %{_mandir}/man8/vgsplit.8.gz
 %{_mandir}/man8/blkdeactivate.8.gz
 %{_mandir}/man8/lvm-dumpconfig.8.gz
+%{_mandir}/man8/lvm-config.8.gz
+%{_mandir}/man8/lvmconfig.8.gz
 %if %{enable_udev}
  %{_udevdir}/11-dm-lvm.rules
  %if %{have_service lvmetad}


