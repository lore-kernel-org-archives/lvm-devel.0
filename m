From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:27:15 -0400
Subject: master - tests: drop unneeded check
Message-ID: <201707101227.v6ACRFRR021644@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c3d8ee4da215444832a0b969945f332e84821b9f
Commit:        c3d8ee4da215444832a0b969945f332e84821b9f
Parent:        4a5eea77581181ee9ddff0c4e3575bc3a73d2585
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 9 13:35:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: drop unneeded check

Test should actually fail in this condition as it's testing lvmetad.
---
 test/shell/lvmetad-dump.sh |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index ecda3ed..3260b73 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -16,9 +16,6 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-# check we can talk to lvmetad
-(echo | aux lvmetad_talk) || skip
-
 aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 lvcreate -n bar -l 1 $vg1


