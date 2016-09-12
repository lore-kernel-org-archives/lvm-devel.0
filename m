From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 12 Sep 2016 12:03:40 +0000 (UTC)
Subject: master - man: Only install lvmraid when needed.
Message-ID: <20160912120340.3429560AAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1768ca599b03646c8d23298a6e64437a11f6133a
Commit:        1768ca599b03646c8d23298a6e64437a11f6133a
Parent:        05dc70e22e58114f0313b0eb9f08c6f75dadc03f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 12 13:03:09 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 12 13:03:09 2016 +0100

man: Only install lvmraid when needed.

---
 WHATS_NEW       |    1 +
 man/Makefile.in |   11 ++++++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 46e0c1a..7c85406 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Don't install lvmraid(7) man page when raid excluded. (2.02.165)
   Report 0% as dirty (copy%) for cache without any used block.
   Fix lvm2api reporting of cache data and metadata percent.
   Restore reporting of metadata usage for cache volumes (2.02.155).
diff --git a/man/Makefile.in b/man/Makefile.in
index 4bc7801..1839c59 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -27,9 +27,10 @@ CMIRRORDMAN = cmirrord.8
 LVMCACHEMAN = lvmcache.7
 LVMTHINMAN = lvmthin.7
 LVMDBUSDMAN = lvmdbusd.8
+LVMRAIDMAN = lvmraid.7
 
 MAN5=lvm.conf.5
-MAN7=lvmsystemid.7 lvmraid.7
+MAN7=lvmsystemid.7
 MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 lvm-lvpoll.8 \
 	lvchange.8 lvmconfig.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 \
 	lvm.8 lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \
@@ -55,7 +56,7 @@ ifeq ($(MAN_ALL),"yes")
   MAN8+=$(FSADMMAN) $(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN)
   MAN8CLUSTER+=$(CLVMDMAN) $(CMIRRORDMAN)
-  MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN)
+  MAN7+=$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMRAIDMAN)
 else
   ifeq ("@FSADM@", "yes")
     MAN8+=$(FSADMMAN)
@@ -100,6 +101,10 @@ else
   ifneq ("@THIN@", "none")
     MAN7+=$(LVMTHINMAN)
   endif
+
+  ifneq ("@RAID@", "none")
+    MAN7+=$(LVMRAIDMAN)
+  endif
 endif
 
 MAN5DIR=$(mandir)/man5
@@ -112,7 +117,7 @@ CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8CLUSTER) \
 	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
 	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
-	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN)
+	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN)
 
 all: man device-mapper
 


