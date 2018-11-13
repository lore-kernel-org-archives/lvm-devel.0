From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Nov 2018 18:28:49 -0500
Subject: master - man lvmdump: remove clvm reference
Message-ID: <201811132328.wADNSnxe006701@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8aec65c0546ffaf5f40ab6fce7616e237cb17960
Commit:        8aec65c0546ffaf5f40ab6fce7616e237cb17960
Parent:        c203ce7f8614226bc2f76f0eba3797e43add3de6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 13 16:20:02 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 13 16:20:02 2018 -0600

man lvmdump: remove clvm reference

---
 man/lvmdump.8_main |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/man/lvmdump.8_main b/man/lvmdump.8_main
index ec3dbb2..2e80ed2 100644
--- a/man/lvmdump.8_main
+++ b/man/lvmdump.8_main
@@ -38,8 +38,6 @@ The content of the tarball is as follows:
 .br
 - if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
 .br
-- if enabled with -c, cluster status info
-.br
 - if enabled with -l, lvmetad state if running
 .br
 - if enabled with -p, lvmpolld state if running
@@ -54,9 +52,6 @@ Advanced collection.
 \fBWARNING\fR: if lvm is already hung, then this script may hang as well
 if \fB-a\fR is used.
 .TP
-.B -c
-If clvmd is running, gather cluster data as well.
-.TP
 .B -d  \fIdirectory
 Dump into a directory instead of tarball
 By default, lvmdump will produce a single compressed tarball containing


