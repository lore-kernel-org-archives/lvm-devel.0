From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  6 Sep 2016 20:21:06 +0000 (UTC)
Subject: master - man lvmraid: install
Message-ID: <20160906202106.5AFC560571@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a54f073af838b611d7099597919f69c24cffea07
Commit:        a54f073af838b611d7099597919f69c24cffea07
Parent:        e1f4fc22d215ed557262a948877c8914a7b94ad1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 6 15:20:43 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 6 15:20:43 2016 -0500

man lvmraid: install

---
 man/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index b923a9a..4bc7801 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -29,7 +29,7 @@ LVMTHINMAN = lvmthin.7
 LVMDBUSDMAN = lvmdbusd.8
 
 MAN5=lvm.conf.5
-MAN7=lvmsystemid.7
+MAN7=lvmsystemid.7 lvmraid.7
 MAN8=lvm-config.8 lvm-dumpconfig.8 lvm-fullreport.8 lvm-lvpoll.8 \
 	lvchange.8 lvmconfig.8 lvconvert.8 lvcreate.8 lvdisplay.8 lvextend.8 \
 	lvm.8 lvmchange.8 lvmconf.8 lvmdiskscan.8 lvmdump.8 lvmsadc.8 lvmsar.8 \


