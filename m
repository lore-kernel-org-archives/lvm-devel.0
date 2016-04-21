From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 21 Apr 2016 21:41:12 +0000 (UTC)
Subject: master - WHATS_NEW: disable lvmetad for lvm1
Message-ID: <20160421214112.B8CE261BDA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9373a0c2ad42d51db6036fc506b9369264d29e6
Commit:        c9373a0c2ad42d51db6036fc506b9369264d29e6
Parent:        01181a299eb26121c963895e3443105eca1e1c60
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 21 16:40:44 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 21 16:40:44 2016 -0500

WHATS_NEW: disable lvmetad for lvm1

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9c15797..1e47c20 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Disable lvmetad when lvm1 metadata is seen, so commands revert to scanning.
   Suppress errors when snapshot merge gets delayed because volume is in use.
   Avoid internal snapshot LV names in messages.
   Autodetect and use /run/lock dir when available instead of /var/lock.


