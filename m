From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Oct 2015 14:52:42 +0000 (UTC)
Subject: master - commands: update command help for -o|--options for reporting commands
Message-ID: <20151030145242.D3905609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd52721b68a7c393a54149649f518f4e2d9440b5
Commit:        dd52721b68a7c393a54149649f518f4e2d9440b5
Parent:        7f125c1116df74d23b442304d8109a784f677251
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 30 15:43:57 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 30 15:47:56 2015 +0100

commands: update command help for -o|--options for reporting commands

---
 tools/commands.h |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index ae5dff7..a141135 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -70,7 +70,7 @@ xx(devtypes,
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
-   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[--rows]\n"
    "\t[-S|--select Selection]\n"
@@ -431,7 +431,7 @@ xx(lvdisplay,
    "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
-   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-S|--select Selection]\n"
    "\t[-P|--partial]\n"
@@ -665,7 +665,7 @@ xx(lvs,
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
-   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
@@ -846,7 +846,7 @@ xx(pvdisplay,
    "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
-   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
@@ -938,7 +938,7 @@ xx(pvs,
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
-   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
@@ -1177,7 +1177,7 @@ xx(vgdisplay,
    "\t[--ignoreskippedcluster]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
-   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[-S|--select Selection]\n"
@@ -1350,7 +1350,7 @@ xx(vgs,
    "\t[--nameprefixes]\n"
    "\t[--noheadings]\n"
    "\t[--nosuffix]\n"
-   "\t[-o|--options [+]Field[,Field]]\n"
+   "\t[-o|--options [+|-|#]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"


