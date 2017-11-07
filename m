From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:36:04 -0500
Subject: master - clvmd: supress ENOENT error on testing connection
Message-ID: <201711072036.vA7Ka4pw007645@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14d0b0bbddb214fbb5dcacfb60d1723d87076bd9
Commit:        14d0b0bbddb214fbb5dcacfb60d1723d87076bd9
Parent:        014122256b50b30324fc848fa79492124bebeb39
Author:        Eric Ren <zren@suse.com>
AuthorDate:    Mon Oct 30 20:53:20 2017 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:24:39 2017 +0100

clvmd: supress ENOENT error on testing connection

In HA cluster, we have "clvm" resource agent to manage clvmd daemon.
The agent invokes clvmd like: "clvmd -T90 -d0", which  always prints
a scaring error message:

"""
local socket: connect failed: No such file or directory
"""

When specifed with "-d" option, clvmd tries to check if an instance
of the clvmd daemon is already running through a testing connection.
The connect() will fail with this ENOENT error in such case, so supress
the error message in such case.

TODO: add missing error reaction code - since ofter log_error, program
is not supposed to continue running (log_error() is for reporting
stopping problems).

Signed-off-by: Eric Ren <zren@suse.com>
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |   14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fdf2c3a..94a7af6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Do not print error when clvmd cannot find running clvmd.
   Prevent start of new merge of snapshot if origin is already being merged.
 
 Version 2.02.176 - 3rd November 2017
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9dbda89..e15a40a 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -2151,6 +2151,14 @@ static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 }
 
 /* Return 0 if we can talk to an existing clvmd */
+/*
+ * FIXME:
+ *
+ * This function returns only -1 or 0, but there are
+ * different levels of errors, some of them should stop
+ * further execution of clvmd thus another state is needed
+ * and some error message need to be only informational.
+ */
 static int check_local_clvmd(void)
 {
 	int local_socket;
@@ -2170,7 +2178,11 @@ static int check_local_clvmd(void)
 
 	if (connect(local_socket,(struct sockaddr *) &sockaddr,
 		    sizeof(sockaddr))) {
-		log_sys_error("connect", "local socket");
+		/* connection failure is expected state */
+		if (errno == ENOENT)
+			log_sys_debug("connect", "local socket");
+		else
+			log_sys_error("connect", "local socket");
 		ret = -1;
 	}
 


