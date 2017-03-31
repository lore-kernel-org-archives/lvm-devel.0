From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 31 Mar 2017 07:54:11 -0400
Subject: master - lvchange: persistent major/minor processing regression
Message-ID: <201703311154.v2VBsBRV014700@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d6ddacf6a1543ba690fc349fad4c0c05cad1183b
Commit:        d6ddacf6a1543ba690fc349fad4c0c05cad1183b
Parent:        0ed087aae504e419ff9712ce8479b04beec38e03
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 31 13:51:39 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 31 13:51:39 2017 +0200

lvchange: persistent major/minor processing regression

Fix a regression introduced by new command line processing
(see starting commit 1e2420bca85da9a37570871cd70192e9ae831786)
causing activation to be rejected in combination with setting
persistent minor device numbers.

Resolves: rhbz1437611
---
 tools/command-lines.in |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 6a73bf8..3e3f480 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -296,12 +296,17 @@ OO: --monitor Bool, OO_LVCHANGE
 ID: lvchange_poll
 DESC: Start or stop processing an LV conversion.
 
-lvchange --persistent y --minor Number LV
-OO: --major Number, OO_LVCHANGE
+lvchange --persistent y --minor Number --activate Active LV
+OO: --minor Number, OO_LVCHANGE
 ID: lvchange_persistent
 DESC: Make the minor device number persistent for an LV.
 RULE: all not LV_thinpool LV_cachepool
 
+lvchange --persistent n --activate LV
+ID: lvchange_persistent
+DESC: Remove the minor device number persistent for an LV.
+RULE: all not LV_thinpool LV_cachepool
+
 ---
 
 OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,


