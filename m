From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2011 12:48:16 -0000
Subject: LVM2/daemons/clvmd clvmd.c
Message-ID: <20110330124816.29217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-30 12:48:16

Modified files:
	daemons/clvmd  : clvmd.c 

Log message:
	Keep noreturn attribute for lvm_thread_fn
	
	Even thought my gcc seems to not need it, as it's deduced from pthread_exit(),
	keep it here for older compiler to avoid getting warnings.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.102&r2=1.103

--- LVM2/daemons/clvmd/clvmd.c	2011/03/30 12:36:20	1.102
+++ LVM2/daemons/clvmd/clvmd.c	2011/03/30 12:48:16	1.103
@@ -132,7 +132,7 @@
 static int local_rendezvous_callback(struct local_client *thisfd, char *buf,
 				     int len, const char *csid,
 				     struct local_client **new_client);
-static void *lvm_thread_fn(void *);
+static void *lvm_thread_fn(void *) __attribute__((noreturn));
 static int add_to_lvmqueue(struct local_client *client, struct clvm_header *msg,
 			   int msglen, const char *csid);
 static int distribute_command(struct local_client *thisfd);


