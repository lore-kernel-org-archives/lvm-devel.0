From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 15:02:52 -0400
Subject: master - man: add dmfilemapd.8
Message-ID: <201703301902.v2UJ2qtb000438@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9fc2b4a3e58d0e36b1ced5a41aceacd5f61e7f1b
Commit:        9fc2b4a3e58d0e36b1ced5a41aceacd5f61e7f1b
Parent:        0ed087aae504e419ff9712ce8479b04beec38e03
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 21:02:29 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 21:02:29 2017 +0200

man: add dmfilemapd.8

---
 man/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index defa9b3..e4ff7fe 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -42,7 +42,7 @@ MAN8=lvm.8 lvmconf.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
      vgrename.8 vgs.8 vgscan.8 vgsplit.8 \
      lvmsar.8 lvmsadc.8 lvmdiskscan.8
 MAN8SO=lvm-config.8 lvm-dumpconfig.8
-MAN8DM=dmsetup.8 dmstats.8
+MAN8DM=dmsetup.8 dmstats.8 dmfilemapd.8
 MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 


