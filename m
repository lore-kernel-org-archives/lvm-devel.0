From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 23:41:31 +0000 (UTC)
Subject: master - spec: add dumpconfig man
Message-ID: <20140327234131.D049F61706@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e02551f041ee59baeed032cccea15330ee24669
Commit:        0e02551f041ee59baeed032cccea15330ee24669
Parent:        6d314466f338a365d00092edea8e62066ef87dc2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 28 00:32:12 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 28 00:41:19 2014 +0100

spec: add dumpconfig man

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index d7502de..0e54bcb 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -131,6 +131,7 @@ fi
 %{_mandir}/man8/vgscan.8.gz
 %{_mandir}/man8/vgsplit.8.gz
 %{_mandir}/man8/blkdeactivate.8.gz
+%{_mandir}/man8/lvm-dumpconfig.8.gz
 %if %{enable_udev}
  %{_udevdir}/11-dm-lvm.rules
  %if %{have_service lvmetad}


