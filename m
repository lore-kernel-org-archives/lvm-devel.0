From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:51 +0000 (UTC)
Subject: master - test: update using exclusive activation
Message-ID: <20130205134751.CC329A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=416eb4b9b352c65e019cbd0a11265050b7360c63
Commit:        416eb4b9b352c65e019cbd0a11265050b7360c63
Parent:        a5b9b4bf02b42baf1f1c033eaa98c5fe23951b43
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 09:20:17 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:39:11 2013 +0100

test: update using exclusive activation

For testing in cluster exclusive activation of origin is needed.
---
 test/shell/snapshot-lvm1.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-lvm1.sh b/test/shell/snapshot-lvm1.sh
index cb55ed6..4d06f0a 100644
--- a/test/shell/snapshot-lvm1.sh
+++ b/test/shell/snapshot-lvm1.sh
@@ -19,7 +19,7 @@ aux prepare_devs 2
 vgcreate --metadatatype 1 $vg $(cat DEVICES)
 
 # Make origin volume
-lvcreate -l5 $vg -n origin
+lvcreate -ae -l5 $vg -n origin
 
 # Create a snap of origin
 lvcreate -s $vg/origin -n snap_with_lvm1_meta -l4


