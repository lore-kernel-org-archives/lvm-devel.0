From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 20 Oct 2010 14:46:46 -0000
Subject: LVM2/daemons/clvmd clvmd-command.c clvmd.c
Message-ID: <20101020144646.24402.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-20 14:46:45

Modified files:
	daemons/clvmd  : clvmd-command.c clvmd.c 

Log message:
	Fix a deadlock in clvmd.
	
	The signalling code (pthread_cond_signal/pthread_cond_wait) in the
	pre_and_post_thread was using the wait mutex (see man pthread_cond_wait)
	incorrectly, and this could cause clvmd to deadlock when timing was
	right. Detailed explanation of the problem follows.
	
	There is a single mutex around (L for Lock, U for Unlock), a signal (S) and a
	wait (W). C for pthread_create. Time flows from left to right, each arrow is a
	thread.
	
	So first the "naive" scenario, with no mutex (PPT = pre_and_post_thread, MCT =
	main clvmd thread; well actually the thread that does read_from_local_sock). I
	will also use X, for a moment when MCT actually waits for something to happen
	that PPT was supposed to do.
	
	MCT -----C ------S--X-----S----X----------------------S------XXXXXXXXX
	|                everything OK up to this --> <-- point...
	PPT       -----WWW-----WWWW------------------------------WWWWWWWWWWWWW
	
	Ok, so pthread API actually does not let you use W/S like that. It goes out of
	its way to tell you that you need a mutex to protect the W so that the above
	cannot happen. *But* if you are creative and just lock around the W's and S's,
	this happens:
	
	MCT ----C-----LSU----X-----LSU----X------------LSU------XXXXXXX
	|
	PPT      ---LWWWU-------LWWWWU-----------------------LWWWWWWWWW
	
	Ooops. Nothing changed (the above is what actually was done by clvmd before
	this satch). So let's do it differently, holding L locked *all* the time in
	PPT, unless we are actually in W (this is something that the pthread API does
	itself, see the man page).
	
	MCT ----C-----LSU------X---LSU---X-----LLLLLLLSU----X----
	|                             (and they live happily ever after)
	PPT     L---WWWWW---------WWWW----------------W----------
	
	So W actually ensures that L is unlocked *atomically* together with entering
	the wait. That means that unless PPT is actually waiting, it cannot be
	signalled by MCT. So if MCT happens to signal it too soon (it wasn't waiting
	yet), it (MCT) will be blocked on the mutex (L), until PPT is actually ready to
	do something.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78

--- LVM2/daemons/clvmd/clvmd-command.c	2010/06/21 15:56:58	1.39
+++ LVM2/daemons/clvmd/clvmd-command.c	2010/10/20 14:46:45	1.40
@@ -210,9 +210,12 @@
 
     if (lock_mode == LCK_UNLOCK) {
 
+        DEBUGLOG("PRE: UNLOCK\n");
 	lkid = (int)(long)dm_hash_lookup(lock_hash, lockname);
-	if (lkid == 0)
+	if (lkid == 0) {
+            DEBUGLOG("lock not found in table\n");
 	    return EINVAL;
+	}
 
 	status = sync_unlock(lockname, lkid);
 	if (status)
@@ -221,6 +224,7 @@
 	    dm_hash_remove(lock_hash, lockname);
     }
     else {
+        DEBUGLOG("PRE: LOCK\n");
 	/* Read locks need to be PR; other modes get passed through */
 	if (lock_mode == LCK_READ)
 	    lock_mode = LCK_PREAD;
--- LVM2/daemons/clvmd/clvmd.c	2010/08/17 16:25:32	1.77
+++ LVM2/daemons/clvmd/clvmd.c	2010/10/20 14:46:45	1.78
@@ -1520,6 +1520,7 @@
 	int pipe_fd = client->bits.localsock.pipe;
 
 	DEBUGLOG("in sub thread: client = %p\n", client);
+	pthread_mutex_lock(&client->bits.localsock.mutex);
 
 	/* Don't start until the LVM thread is ready */
 	pthread_mutex_lock(&lvm_start_mutex);
@@ -1564,7 +1565,6 @@
 		}
 
 		/* We may need to wait for the condition variable before running the post command */
-		pthread_mutex_lock(&client->bits.localsock.mutex);
 		DEBUGLOG("Waiting to do post command - state = %d\n",
 			 client->bits.localsock.state);
 
@@ -1573,7 +1573,6 @@
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
 		}
-		pthread_mutex_unlock(&client->bits.localsock.mutex);
 
 		DEBUGLOG("Got post command condition...\n");
 
@@ -1594,16 +1593,15 @@
 next_pre:
 		DEBUGLOG("Waiting for next pre command\n");
 
-		pthread_mutex_lock(&client->bits.localsock.mutex);
 		if (client->bits.localsock.state != PRE_COMMAND &&
 		    !client->bits.localsock.finished) {
 			pthread_cond_wait(&client->bits.localsock.cond,
 					  &client->bits.localsock.mutex);
 		}
-		pthread_mutex_unlock(&client->bits.localsock.mutex);
 
 		DEBUGLOG("Got pre command condition...\n");
 	}
+	pthread_mutex_unlock(&client->bits.localsock.mutex);
 	DEBUGLOG("Subthread finished\n");
 	pthread_exit((void *) 0);
 }


