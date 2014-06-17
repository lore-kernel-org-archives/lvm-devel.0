From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 14:34:43 +0000 (UTC)
Subject: master - report: select: add --select arg to lvm devtypes
Message-ID: <20140617143443.7626060C4E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40e0f444955690d4c5a5c5da8320a65e23a50553
Commit:        40e0f444955690d4c5a5c5da8320a65e23a50553
Parent:        f88130fd8543c3fd5829afb1bc4e4bd30a255d0c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 13 12:57:22 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 16:27:21 2014 +0200

report: select: add --select arg to lvm devtypes

---
 tools/commands.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 4504126..019d4ef 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -42,6 +42,7 @@ xx(devtypes,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[--rows]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
    "\t[--unquoted]\n"
@@ -50,7 +51,7 @@ xx(devtypes,
 
    aligned_ARG, nameprefixes_ARG,
    noheadings_ARG, nosuffix_ARG, options_ARG,
-   rows_ARG, separator_ARG, sort_ARG,
+   rows_ARG, select_ARG, separator_ARG, sort_ARG,
    unbuffered_ARG, unquoted_ARG)
 
 xx(dumpconfig,


