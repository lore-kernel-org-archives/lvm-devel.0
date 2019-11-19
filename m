From: David Teigland <teigland@sourceware.org>
Date: Tue, 19 Nov 2019 12:01:15 -0500
Subject: master - lvs: disable scanning optimization
Message-ID: <42306.119111912010905925@us-mta-217.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7474440d3b540d20eb4f997efeb31b881cc6ac8e
Commit:        7474440d3b540d20eb4f997efeb31b881cc6ac8e
Parent:        f88f7c0fdcdfbefa37df6adb36a637526bd7e93b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 19 10:27:02 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 19 10:56:12 2019 -0600

lvs: disable scanning optimization

The scanning optimization can produce warnings from
'lvs' when run concurrently with commands modifying LVs,
so disable the optimization until it can be improved.

Without the scanning optimization, lvs will always
read all PVs twice:

1. read metadata from all PVs, saving it in memory
2. for each VG
3. lock VG
4. reread metadata from all PVs in VG, replacing metadata
   saved from step 1
5. run command on VG
6. unlock VG

The optimization would usually cause step 4 to be skipped,
and PVs would be read only once.

Running the command in step 5 using metadata that was not
read under the VG lock is usually fine, except for the
fact that lvs attempts to validate the metadata by comparing
it to current dm state.  If other commands are modifying dm
state while lvs is running, lvs may see differences between
metadata from step 1 and dm state checked during step 5,
and print warnings.

(A better fix may be to detect the concurrent change and
fall back to rereading metadata in step 4 only when needed.)
---
 tools/commands.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index c1670ae..77cf1fa 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -99,7 +99,7 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",



