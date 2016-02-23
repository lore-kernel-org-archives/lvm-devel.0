From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 13:41:44 +0000 (UTC)
Subject: master - gcc: cleanup Wunused-const-variable
Message-ID: <20160223134144.DD89161098@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05cc1b87a952995c54ad99b8e9a0da9479bb56a5
Commit:        05cc1b87a952995c54ad99b8e9a0da9479bb56a5
Parent:        e717ce555bffc9e8ea2dd981f733e55a2cde26ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 12:59:46 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:41:24 2016 +0100

gcc: cleanup  Wunused-const-variable

Use #define instead, since we do not require actually buffer needs
to exists to eliminated new gcc6 warning:

clvm.h:53:19: warning: ???????CLVMD_SOCKNAME???????? defined but not used
[-Wunused-const-variable]
---
 daemons/clvmd/clvm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/clvmd/clvm.h b/daemons/clvmd/clvm.h
index 75cc296..ae0a13a 100644
--- a/daemons/clvmd/clvm.h
+++ b/daemons/clvmd/clvm.h
@@ -50,7 +50,7 @@ struct clvm_header {
 #define CLVMD_FLAG_REMOTE	8	/* Do this on all nodes except for the local node */
 
 /* Name of the local socket to communicate between lvm and clvmd */
-static const char CLVMD_SOCKNAME[]= DEFAULT_RUN_DIR "/clvmd.sock";
+#define CLVMD_SOCKNAME		DEFAULT_RUN_DIR "/clvmd.sock"
 
 /* Internal commands & replies */
 #define CLVMD_CMD_REPLY    1


