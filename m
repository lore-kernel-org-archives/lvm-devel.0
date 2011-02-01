From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 1 Feb 2011 10:00:09 -0600
Subject: [PATCH 1 of 2] LVM: fix decode_lock_type
Message-ID: <201102011600.p11G09Hd019265@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-fix-decode_lock_type.patch

fix bad 'strcmp's

There was no effect from having this wrong yet, because the
tree of callers only ever cared about the answer to the first
condition (!response), which determines whether a lock is
held or not.  Correct responses, however, are needed soon.

Index: LVM2/lib/locking/cluster_locking.c
===================================================================
--- LVM2.orig/lib/locking/cluster_locking.c
+++ LVM2/lib/locking/cluster_locking.c
@@ -490,11 +490,11 @@ static int decode_lock_type(const char *
 {
 	if (!response)
 		return LCK_NULL;
-	else if (strcmp(response, "EX"))
+	else if (!strcmp(response, "EX"))
 		return LCK_EXCL;
-	else if (strcmp(response, "CR"))
+	else if (!strcmp(response, "CR"))
 		return LCK_READ;
-	else if (strcmp(response, "PR"))
+	else if (!strcmp(response, "PR"))
 		return LCK_PREAD;
 
 	stack;
@@ -532,8 +532,8 @@ int query_resource(const char *resource,
 
 		/*
 		 * All nodes should use CR, or exactly one node
-		 * should held EX. (PR is obsolete)
-		 * If two nodes node reports different locks,
+		 * should hold EX. (PR is obsolete)
+		 * If two nodes report different locks,
 		 * something is broken - just return more important mode.
 		 */
 		if (decode_lock_type(response[i].response) > *mode)


