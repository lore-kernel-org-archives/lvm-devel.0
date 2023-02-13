From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:40 +0000 (GMT)
Subject: main - configure.ac: fix support for LOCKDIDM
Message-ID: <20230213133140.A255F383FB93@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6efa827ee764d0297ee1631f3a96507a18f9488
Commit:        b6efa827ee764d0297ee1631f3a96507a18f9488
Parent:        7f2864b5b1b1174846c3131f6c3962bd3806da72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 10 22:53:43 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 14:30:47 2023 +0100

configure.ac: fix support for LOCKDIDM

Commit 7a8b7b4adde5c31c79aee8b0792cd8369652afc6 introducing lockidm
support missed to use AC_SUBST() for a variable and provide it only
in prebuilt configure, so with the next autoreconf this variable
was lost and IDM support was no longer compiled.

Fixes: https://github.com/lvmteam/lvm2/issues/98
Reported-by: Tom Prohofsky
---
 configure.ac | 1 +
 1 file changed, 1 insertion(+)

diff --git a/configure.ac b/configure.ac
index 1c4d5fd1f..ae7b9d8c5 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1826,6 +1826,7 @@ AC_SUBST(BUILD_LVMLOCKD)
 AC_SUBST(BUILD_LOCKDSANLOCK)
 AC_SUBST(BUILD_LOCKDDLM)
 AC_SUBST(BUILD_LOCKDDLM_CONTROL)
+AC_SUBST(BUILD_LOCKDIDM)
 AC_SUBST(BUILD_DMFILEMAPD)
 AC_SUBST(CACHE)
 AC_SUBST(CFLAGS)

