From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Jan 2014 10:02:56 +0000 (UTC)
Subject: master - libdm: WHATSNEW
Message-ID: <20140117100256.9062660CFF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f9035363684953d66c076f0f874d12d0576b4b2
Commit:        5f9035363684953d66c076f0f874d12d0576b4b2
Parent:        0638d1d82e349c332ea2e7e6be96f4b1f4fc5c2e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 17 11:02:29 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 17 11:02:29 2014 +0100

libdm: WHATSNEW

---
 WHATS_NEW_DM |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index effd0cc..af82096 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.84 -
 ====================================
+  Deactive already actived nodes when node's preload callback fails.
   Avoid busy looping on CPU when dmeventd reads event DM_WAIT_RETRY.
   Ensure global mutex is being hold when working with dmeventd thread.
   Drop taking timeout mutex for un/registering dmeventd monitor.


