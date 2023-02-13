From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:41 +0000 (GMT)
Subject: main - configure.ac: remove UDEV_SYSTEMD_BACKGROUND_JOBS
Message-ID: <20230213133141.C219F3858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f46610e9b0a75ce9610c146a317cfc6dfe1ac6f0
Commit:        f46610e9b0a75ce9610c146a317cfc6dfe1ac6f0
Parent:        b6efa827ee764d0297ee1631f3a96507a18f9488
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 15:42:31 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 14:30:47 2023 +0100

configure.ac: remove UDEV_SYSTEMD_BACKGROUND_JOBS

Missed to go with 042fbd43d25f4cc69ceec1aea4d0658bec54b6e3.
---
 configure.ac | 1 -
 1 file changed, 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index ae7b9d8c5..079bbd07f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1941,7 +1941,6 @@ AC_SUBST(CACHE_RESTORE_CMD)
 AC_SUBST(UDEV_PC)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
-AC_SUBST(UDEV_SYSTEMD_BACKGROUND_JOBS)
 AC_SUBST(UDEV_RULE_EXEC_DETECTION)
 AC_SUBST(UDEV_HAS_BUILTIN_BLKID)
 AC_SUBST(USE_TRACKING)

