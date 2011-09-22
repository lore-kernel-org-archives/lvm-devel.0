From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Sep 2011 11:52:48 +0200
Subject: [PATCH 1/3] Add named cluster_ops
In-Reply-To: <cover.1316684951.git.zkabelac@redhat.com>
References: <cover.1316684951.git.zkabelac@redhat.com>
Message-ID: <1d6a7b584522dd2c752be768d9356f06a7934334.1316684951.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

To easily learn the name of the active cluster ops.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd-cman.c       |    1 +
 daemons/clvmd/clvmd-command.c    |   10 ++++------
 daemons/clvmd/clvmd-comms.h      |    3 ++-
 daemons/clvmd/clvmd-corosync.c   |    1 +
 daemons/clvmd/clvmd-openais.c    |    1 +
 daemons/clvmd/clvmd-singlenode.c |    1 +
 6 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/daemons/clvmd/clvmd-cman.c b/daemons/clvmd/clvmd-cman.c
index c7a2b2d..7e76dc4 100644
--- a/daemons/clvmd/clvmd-cman.c
+++ b/daemons/clvmd/clvmd-cman.c
@@ -479,6 +479,7 @@ static int _get_cluster_name(char *buf, int buflen)
 }
 
 static struct cluster_ops _cluster_cman_ops = {
+	.name                     = "cman",
 	.cluster_init_completed   = _cluster_init_completed,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 4ba7151..bd6e55e 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -380,7 +380,7 @@ static int restart_clvmd(void)
 	} while (hn);
 
 	/* clvmd + locks (-E uuid) + debug (-d X) + NULL */
-	if (!(argv = malloc((max_locks * 2 + 4) * sizeof(*argv))))
+	if (!(argv = malloc((max_locks * 2 + 5) * sizeof(*argv))))
 		goto_out;
 
 	/*
@@ -395,10 +395,8 @@ static int restart_clvmd(void)
 		argv[argc++] = debug_arg;
 	}
 
-	/*
-	 * FIXME: specify used cluster backend
-	 * argv[argc++] = strdup("-Isinglenode");
-	 */
+	argv[argc++] = "-I";
+	argv[argc++] = clops->name;
 
 	/* Now add the exclusively-open LVs */
 	hn = NULL;
diff --git a/daemons/clvmd/clvmd-comms.h b/daemons/clvmd/clvmd-comms.h
index 500bd57..7207334 100644
--- a/daemons/clvmd/clvmd-comms.h
+++ b/daemons/clvmd/clvmd-comms.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -23,6 +23,7 @@
 struct local_client;
 
 struct cluster_ops {
+	const char *name;
 	void (*cluster_init_completed) (void);
 
 	int (*cluster_send_message) (const void *buf, int msglen,
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index 01ee09f..e929681 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -598,6 +598,7 @@ out:
 }
 
 static struct cluster_ops _cluster_corosync_ops = {
+	.name                     = "corosync",
 	.cluster_init_completed   = NULL,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
diff --git a/daemons/clvmd/clvmd-openais.c b/daemons/clvmd/clvmd-openais.c
index 0cfb637..a2fe69e 100644
--- a/daemons/clvmd/clvmd-openais.c
+++ b/daemons/clvmd/clvmd-openais.c
@@ -667,6 +667,7 @@ static int _get_cluster_name(char *buf, int buflen)
 }
 
 static struct cluster_ops _cluster_openais_ops = {
+	.name                     = "openais",
 	.cluster_init_completed   = NULL,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index aba4fa6..be04880 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -267,6 +267,7 @@ static int _get_cluster_name(char *buf, int buflen)
 }
 
 static struct cluster_ops _cluster_singlenode_ops = {
+	.name                     = "singlenode",
 	.cluster_init_completed   = NULL,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
-- 
1.7.6.2


