From: okozina <okozina@fedoraproject.org>
Date: Tue, 26 May 2015 14:29:49 +0000 (UTC)
Subject: master - WHATS_NEW: various updates
Message-ID: <20150526142949.B822160B47@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0268585dd962a7b0393160c042fefb72c64701c
Commit:        f0268585dd962a7b0393160c042fefb72c64701c
Parent:        8af5f54824f889c438104625dbe159f6e8dedbc4
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 26 16:08:24 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 26 16:28:04 2015 +0200

WHATS_NEW: various updates

commit c069aff21b1450923b59e98ab709a5e667cdcda9
commit 8af5f54824f889c438104625dbe159f6e8dedbc4
---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29eb501..bfcc094 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.121 - 
 ================================
+  Zero errno in before strtoul call in dmsetup if tested after the call.
+  Zero errno in before strtoul call in lvmpolld.
   Fix a segfault in pvscan --cache --background command.
   Fix test for AREA_PV when checking for failed mirrors.
   Do not use --sysinit in lvm2-activation{-early,-net}.service if lvmpolld used.


