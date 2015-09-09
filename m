From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  9 Sep 2015 20:43:51 +0000 (UTC)
Subject: master - man lvmlockd: fix typo
Message-ID: <20150909204351.40C996034D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d323acdfec8aaab1161aa5f80ae67622e396a632
Commit:        d323acdfec8aaab1161aa5f80ae67622e396a632
Parent:        81b0e9de7c28e1516263427d270907c4781964e1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 15:43:28 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 9 15:43:28 2015 -0500

man lvmlockd: fix typo

---
 man/lvmlockd.8.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index 15f9b73..8567651 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -309,8 +309,8 @@ contain the "global lock".
 The first vgcreate command needs to be given the path to a device that has
 not yet been initialized with pvcreate.  The pvcreate initialization will
 be done by vgcreate.  This is because the pvcreate command requires the
-global lock, which will not available until after the first sanlock VG is
-created.
+global lock, which will not be available until after the first sanlock VG
+is created.
 
 .IP \[bu] 2
 While running vgcreate for the first sanlock VG, ensure that the device


