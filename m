From: David Teigland <teigland@sourceware.org>
Date: Mon, 28 Sep 2020 18:29:29 +0000 (GMT)
Subject: master - lvpoll: don't use hints
Message-ID: <20200928182929.B4FA73945055@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df6f16c081ffca48f2c812e539851995b7563b68
Commit:        df6f16c081ffca48f2c812e539851995b7563b68
Parent:        da14cf68cb62e1bf2e9718358158dde48a1acd20
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 25 12:29:10 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 28 13:25:57 2020 -0500

lvpoll: don't use hints

There's a bug when lvpoll attempts to write new hints,
related to the fact that lvpoll does not follow the same
scanning process as standard commands.
Fix by disabling the use of hints in lvpoll.  We may want
to renable hints in lvpoll in a way that they can be used,
if valid, but not updated if they don't exist or are invalid.
---
 tools/commands.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/commands.h b/tools/commands.h
index c1670ae66..ae1bf3934 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -137,7 +137,7 @@ xx(pvmove,
 
 xx(lvpoll,
    "Continue already initiated poll operation on a logical volume",
-   ALLOW_HINTS)
+   0)
 
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",


