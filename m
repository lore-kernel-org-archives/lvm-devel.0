From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Mar 2010 14:38:57 -0000
Subject: LVM2/daemons/dmeventd/plugins/lvm2 dmeventd_lvm.c
Message-ID: <20100330143857.18399.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-30 14:38:56

Modified files:
	daemons/dmeventd/plugins/lvm2: dmeventd_lvm.c 

Log message:
	Release pool in the same reversed order
	and with lowered priority after _memlock_dec.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/01/21 22:15:46	1.1
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/03/30 14:38:56	1.2
@@ -105,11 +105,11 @@
 	pthread_mutex_lock(&_register_mutex);
 
 	if (!--_register_count) {
-		dm_pool_destroy(_mem_pool);
-		_mem_pool = NULL;
 		lvm2_run(_lvm_handle, "_memlock_dec");
 		lvm2_exit(_lvm_handle);
 		_lvm_handle = NULL;
+		dm_pool_destroy(_mem_pool);
+		_mem_pool = NULL;
 	}
 
 	pthread_mutex_unlock(&_register_mutex);


