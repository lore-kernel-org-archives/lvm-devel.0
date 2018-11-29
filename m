From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Nov 2018 17:13:04 -0500
Subject: master - tests: add mising udev_wait
Message-ID: <201811292213.wATMD4vl016648@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74731a5277eb02347902801c4ec5b087deecc580
Commit:        74731a5277eb02347902801c4ec5b087deecc580
Parent:        e3a22cdc31c38939efd51dd9a3a82e034adc21c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 20 16:01:12 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 29 23:10:08 2018 +0100

tests: add mising udev_wait

mdadm does not handle udev waiting so it may exit earlier,
while devices are still 'running'.
---
 test/shell/lvm-on-md.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvm-on-md.sh b/test/shell/lvm-on-md.sh
index ec8cc23..a3e83d9 100644
--- a/test/shell/lvm-on-md.sh
+++ b/test/shell/lvm-on-md.sh
@@ -52,6 +52,7 @@ pvs
 vgchange -an $vg
 
 mdadm --stop "$mddev"
+aux udev_wait
 
 # with md superblock 1.0 this pvs will report duplicates
 # for the two md legs since the md device itself is not
@@ -70,6 +71,7 @@ lvs $vg
 
 # start the md dev
 mdadm --assemble "$mddev" "$dev1" "$dev2"
+aux udev_wait
 
 # Now that the md dev is online, pvs can see it and
 # ignore the two legs, so there's no duplicate warning


