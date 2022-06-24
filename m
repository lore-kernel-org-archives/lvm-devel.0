From: David Teigland <teigland@sourceware.org>
Date: Fri, 24 Jun 2022 15:44:53 +0000 (GMT)
Subject: main - pvdisplay: restore --reportformat option
Message-ID: <20220624154453.34D58384146E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db5277c97155632ce83e1125e348eda97c871968
Commit:        db5277c97155632ce83e1125e348eda97c871968
Parent:        3b0f9cec7e999c33f17714358d2b469bda6967d2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jun 24 10:40:54 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 24 10:40:54 2022 -0500

pvdisplay: restore --reportformat option

Fixes commit b8f4ec846 "display: ignore --reportformat"
by restoring the --reportformat option to pvdisplay.
Adding -C to pvdisplay turns the command into a reporting
command (like pvs, vgs, lvs) in which --reportformat can
be useful.
---
 tools/command-lines.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index b64fd0dda..b6a03d158 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1593,10 +1593,10 @@ pvdisplay
 OO: --aligned, --all, --binary, --colon, --columns, --configreport ConfigReport,
 --foreign, --ignorelockingfailure,
 --logonly, --maps, --noheadings, --nosuffix, --options String,
---readonly, --select String, --separator String, --shared,
+--readonly, --reportformat ReportFmt, --select String, --separator String, --shared,
 --short, --sort String, --unbuffered, --units Units
 OP: PV|Tag ...
-IO: --ignoreskippedcluster, --reportformat ReportFmt
+IO: --ignoreskippedcluster
 ID: pvdisplay_general
 
 ---

