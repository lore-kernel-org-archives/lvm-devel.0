From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 18 Nov 2009 18:22:33 -0000
Subject: LVM2/lib/mm memlock.c
Message-ID: <20091118182233.28286.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-18 18:22:33

Modified files:
	lib/mm         : memlock.c 

Log message:
	Issue an Internal error message whenever _memlock_count drops below 0.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mm/memlock.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/lib/mm/memlock.c	2008/05/28 23:12:45	1.12
+++ LVM2/lib/mm/memlock.c	2009/11/18 18:22:32	1.13
@@ -135,6 +135,8 @@
 	if (_memlock_count && (!--_memlock_count))
 		_unlock_mem();
 	log_debug("memlock_count dec to %d", _memlock_count);
+	if (_memlock_count < 0)
+		log_error("Internal error: _memlock_count has dropped below 0.");
 }
 
 int memlock(void)


