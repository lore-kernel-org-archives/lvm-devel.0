From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Nov 2019 17:52:52 -0500
Subject: master - Revert "lvs: disable scanning optimization"
Message-ID: <54704.119112617524701367@us-mta-314.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a61272a6f048e56ea75e34ad190af10ff9773c8c
Commit:        a61272a6f048e56ea75e34ad190af10ff9773c8c
Parent:        0c1316cda876849d5d1375d40e8cdc08db37c2b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 26 12:01:24 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 26 16:52:28 2019 -0600

Revert "lvs: disable scanning optimization"

This reverts commit 7474440d3b540d20eb4f997efeb31b881cc6ac8e.

lvs can use the scanning optimization again since it has
been changed in:
"scanning: optimize by checking text offset and checksum"
---
 tools/commands.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 77cf1fa..c1670ae 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -99,7 +99,7 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",



