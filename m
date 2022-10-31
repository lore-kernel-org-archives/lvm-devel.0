From: David Teigland <teigland@sourceware.org>
Date: Mon, 31 Oct 2022 13:56:12 +0000 (GMT)
Subject: main - vgchange systemid: use tag or select
Message-ID: <20221031135612.63F9D385DC38@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81f10c1d1e844dd3ad9918a31a0d7c00fed36c94
Commit:        81f10c1d1e844dd3ad9918a31a0d7c00fed36c94
Parent:        f188c9e40319d00a3d5bd59f1d01016325935da6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 31 08:54:33 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 31 08:54:33 2022 -0500

vgchange systemid: use tag or select

The command can do this but the command defs
were missing the annotation to allow it.
---
 tools/command-lines.in | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index ec61d3b7d..4bbafd05d 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1766,7 +1766,8 @@ IO: --ignoreskippedcluster
 ID: vgchange_refresh
 DESC: Reactivate LVs using the latest metadata.
 
-vgchange --systemid String VG
+vgchange --systemid String VG|Tag|Select
+OO: --select String
 ID: vgchange_systemid
 DESC: Change the system ID of a VG.
 

