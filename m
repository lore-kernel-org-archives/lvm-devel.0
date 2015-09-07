From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 21:30:51 +0000 (UTC)
Subject: master - specs: install lvmlockctl only when built
Message-ID: <20150907213051.0540660FB4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0ec64370b24acf837c725b614db993a663cc8103
Commit:        0ec64370b24acf837c725b614db993a663cc8103
Parent:        d7f45ebca52ecb7e15dee42f81718266b127bb5c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 23:27:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 23:27:50 2015 +0200

specs: install lvmlockctl only when built

Move install line into proper section.
---
 spec/packages.inc |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 7e59068..69643ef 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -105,7 +105,6 @@ fi
 %{_mandir}/man8/lvmconf.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
 %{_mandir}/man8/lvmdump.8.gz
-%{_mandir}/man8/lvmlockctl.8.gz
 %{_mandir}/man8/lvmsadc.8.gz
 %{_mandir}/man8/lvmsar.8.gz
 %{_mandir}/man8/lvreduce.8.gz
@@ -285,6 +284,7 @@ LVM commands use lvmlockd to coordinate access to shared storage.
 %{_sbindir}/lvmlockd
 %{_sbindir}/lvmlockctl
 %{_mandir}/man8/lvmlockd.8.gz
+%{_mandir}/man8/lvmlockctl.8.gz
 %dir %{_default_locking_dir}
 %{_unitdir}/lvm2-lvmlockd.service
 %{_unitdir}/lvm2-lvmlocking.service


