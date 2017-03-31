From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 31 Mar 2017 11:10:41 -0400
Subject: master - lvchange: persistent major/minor processing regression
Message-ID: <201703311510.v2VFAfZP008068@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13ca11cc1472fe5689e63555780acfb40cb3bcd9
Commit:        13ca11cc1472fe5689e63555780acfb40cb3bcd9
Parent:        d6ddacf6a1543ba690fc349fad4c0c05cad1183b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 31 17:09:33 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 31 17:09:33 2017 +0200

lvchange: persistent major/minor processing regression

Optimized change.

Resolves: rhbz1437611
---
 tools/command-lines.in |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 3e3f480..6a345f3 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -296,17 +296,12 @@ OO: --monitor Bool, OO_LVCHANGE
 ID: lvchange_poll
 DESC: Start or stop processing an LV conversion.
 
-lvchange --persistent y --minor Number --activate Active LV
-OO: --minor Number, OO_LVCHANGE
+lvchange --persistent y --minor Number LV
+OO: --major Number, --activate Activate OO_LVCHANGE
 ID: lvchange_persistent
 DESC: Make the minor device number persistent for an LV.
 RULE: all not LV_thinpool LV_cachepool
 
-lvchange --persistent n --activate LV
-ID: lvchange_persistent
-DESC: Remove the minor device number persistent for an LV.
-RULE: all not LV_thinpool LV_cachepool
-
 ---
 
 OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,


