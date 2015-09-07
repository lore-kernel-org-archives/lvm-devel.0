From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:30 +0000 (UTC)
Subject: master - specs: package lvmlockctl man page
Message-ID: <20150907154530.44DBE60E5D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=330cad15678116fadd33737d69d3bba3b926fc30
Commit:        330cad15678116fadd33737d69d3bba3b926fc30
Parent:        fa4d2ec24139ddc9e5ce69dde20155f308e09335
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 16:40:46 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:44:08 2015 +0200

specs: package lvmlockctl man page

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index fc68335..7e59068 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -105,6 +105,7 @@ fi
 %{_mandir}/man8/lvmconf.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
 %{_mandir}/man8/lvmdump.8.gz
+%{_mandir}/man8/lvmlockctl.8.gz
 %{_mandir}/man8/lvmsadc.8.gz
 %{_mandir}/man8/lvmsar.8.gz
 %{_mandir}/man8/lvreduce.8.gz


