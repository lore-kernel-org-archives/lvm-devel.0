From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 24 Jun 2016 12:52:17 +0000 (UTC)
Subject: master - commands: help: add missing --reportformat references
Message-ID: <20160624125217.09BB26029E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a414245b908bfa1bacb12b6416908de65f0e317
Commit:        9a414245b908bfa1bacb12b6416908de65f0e317
Parent:        14da3cc793a368f925f26706e6b50f91a6dbede1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 24 14:49:13 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 24 14:49:13 2016 +0200

commands: help: add missing --reportformat references

---
 tools/commands.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 5589c9e..c348753 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -158,7 +158,7 @@ xx(fullreport,
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
-   "\t[--reportformat {json}]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[--rows]\n"
    "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
@@ -181,7 +181,7 @@ xx(lastlog,
    "Display last command's log report",
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
    "log\n"
-   "\t[--reportformat {json}]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n",
 
    reportformat_ARG, select_ARG)
@@ -472,6 +472,7 @@ xx(lvdisplay,
    "\t[--nosuffix]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
@@ -908,6 +909,7 @@ xx(pvdisplay,
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[-s|--short]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
@@ -1263,6 +1265,7 @@ xx(vgdisplay,
    "\t[--nosuffix]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[--reportformat {basic|json}]\n"
    "\t[-S|--select Selection]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--version]\n"


