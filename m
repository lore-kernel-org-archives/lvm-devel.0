From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:18 +0000 (UTC)
Subject: master - commands: lvremove: recognize --nohistory option
Message-ID: <20160303132018.CC9E160308@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1399090cd7db6d16e10ddf0a7b0ca72e254c63c
Commit:        b1399090cd7db6d16e10ddf0a7b0ca72e254c63c
Parent:        f545dd5952ee0b191ae2cda2d7b6f304442debab
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:25:37 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

commands: lvremove: recognize --nohistory option

---
 tools/commands.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index ffc15b5..97f7de1 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -598,6 +598,7 @@ xx(lvremove,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[--nohistory]\n"
    "\t[--noudevsync]\n"
    "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
@@ -605,7 +606,7 @@ xx(lvremove,
    "\t[--version]\n"
    "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
 
-   autobackup_ARG, force_ARG, noudevsync_ARG, select_ARG, test_ARG)
+   autobackup_ARG, force_ARG, nohistory_ARG, noudevsync_ARG, select_ARG, test_ARG)
 
 xx(lvrename,
    "Rename a logical volume",


