From: okozina <okozina@fedoraproject.org>
Date: Fri, 15 May 2015 18:37:21 +0000 (UTC)
Subject: master - commands.h: reorder lvpoll options
Message-ID: <20150515183721.136EB610DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e93058ed814f4e669287a6c5e8fa913130f2d591
Commit:        e93058ed814f4e669287a6c5e8fa913130f2d591
Parent:        ce3c457dcc4385c6740bacf1b0e9ca7575ab8c10
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Thu May 14 19:33:54 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Fri May 15 20:32:25 2015 +0200

commands.h: reorder lvpoll options

---
 tools/commands.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index bbfcd72..8e87681 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -884,12 +884,13 @@ xx(lvpoll,
    "Continue already initiated poll operation on a logical volume",
    0,
    "\t[--abort]\n"
-   "\t[--handlemissingpvs]\n"
-   "\t[--polloperation\n"
    "\t[-A|--autobackup {y|n}]\n"
+   "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n "
    "\t[-h|-?|--help]\n"
+   "\t[--handlemissingpvs]\n"
    "\t[-i|--interval seconds]\n"
+   "\t[--polloperation]\n"
    "\t[-t|--test]\n "
    "\t[-v|--verbose]\n "
    "\t[--version]\n",


