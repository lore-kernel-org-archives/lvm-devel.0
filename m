From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 6 May 2019 07:03:55 -0400
Subject: master - tests: drop call of wipefs
Message-ID: <201905061103.x46B3tPs010243@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4ff472b9071e2a6efef96e425cbe38cc63280189
Commit:        4ff472b9071e2a6efef96e425cbe38cc63280189
Parent:        9f561f2206bd893ea5ef7052debaff2af97006d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 4 19:11:00 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 4 19:11:00 2019 +0200

tests: drop call of wipefs

wipefs might not be present on test system.
Devices are also already zeroed by cleanup_md_dev
(which 'fakes' missing wipefs eventually)
---
 test/shell/lvm-on-md.sh |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index 4c66431..41649be 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -124,10 +124,6 @@ vgremove -f $vg
 
 aux cleanup_md_dev
 
-wipefs -a "$dev1"
-wipefs -a "$dev2"
-
-
 # create 2 disk MD raid0 array
 # by default using metadata format 1.0 with data at the end of device
 # When a raid0 md array is stopped, the components will not look like


