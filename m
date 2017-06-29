From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:31 -0400
Subject: master - clvmd_fix_conf.sh: legacy code
Message-ID: <201706292027.v5TKRV7g026656@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99925d0d416dd7664af0fc507480499f44a7915e
Commit:        99925d0d416dd7664af0fc507480499f44a7915e
Parent:        afa0bd916e9b54530ad2eb99373c836c5396ea4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 22:03:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

clvmd_fix_conf.sh: legacy code

Use $(..) instead of legacy `..`.
---
 scripts/clvmd_fix_conf.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/clvmd_fix_conf.sh b/scripts/clvmd_fix_conf.sh
index cc2c50d..079cf30 100644
--- a/scripts/clvmd_fix_conf.sh
+++ b/scripts/clvmd_fix_conf.sh
@@ -52,8 +52,8 @@ then
 fi
 
 
-SCRIPTFILE=`mktemp -t lvmscript.XXXXXXXXXX`
-TMPFILE=`mktemp -t lvmtmp.XXXXXXXXXX`
+SCRIPTFILE=$(mktemp -t lvmscript.XXXXXXXXXX)
+TMPFILE=$(mktemp -t lvmtmp.XXXXXXXXXX)
 
 
 # Flags so we know which parts of the file we can replace and which need


