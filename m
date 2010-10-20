From: Milan Broz <mbroz@redhat.com>
Date: Wed, 20 Oct 2010 12:40:48 +0200
Subject: [PATCH] (DRAFT!) Fix a deadlock in CLVMD (possibly related to BZ 561226).
In-Reply-To: <874ocje7y1.fsf@twilight.int.mornfall.net.>
References: <874ocje7y1.fsf@twilight.int.mornfall.net.>
Message-ID: <4CBEC730.4020906@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/18/2010 07:17 PM, Petr Rockai wrote:
> the signalling code (pthread_cond_signal/pthread_cond_wait) in the
> pre_and_post_thread in clvmd is using the wait mutex (see man
> pthread_cond_wait) incorrectly, and this can cause clvmd to completely
> deadlock when the timing is right.

well, nobody even tried to answer, despite this quite important problem...

So, I see these important items:

1) always rely on implicit unlock in pthread_cond_wait()

2) some of the code now runs with client->bits.localsock.mutex locked,
mainly the do_pre_command() and do_post_command() + socket writes

3) the common code to signal is _only_ this pattern

	pthread_mutex_lock(&client->bits.localsock.mutex);
	client->bits.localsock.state = <STATE>;
	pthread_cond_signal(&client->bits.localsock.cond);
	pthread_mutex_unlock(&client->bits.localsock.mutex);

this is called from request_timed_out() and read_from_local_sock()
and it wakes up thrad always waiting in this code pattern

	pthread_cond_wait(&client->bits.localsock.cond,
			  &client->bits.localsock.mutex);

I didn't found any other uses for this lock.

So the thread is signaled only when in cond_wait now (there is no
other place where signaling thread can take lock now).

This seems as expected fix.

The post/pre routines should not have problems with running with
localsock.mutex taken, same for socket writes - hope I am right:-)

Did I miss or misinterpret anything?

Not extra deep analysis, but for me it seems like correct fix,
I think we should commit it and run some tests...

Milan

p.s.
nitpicking

	DEBUGLOG("in sub thread: client = %p\n", client);
	+ pthread_mutex_lock(&client->bits.localsock.mutex);

	/* Don't start until the LVM thread is ready */
	pthread_mutex_lock(&lvm_start_mutex);
	pthread_mutex_unlock(&lvm_start_mutex);
	DEBUGLOG("Sub thread ready for work.\n");


Can we move that localsock.muext lock after the lvm_start_mutex exercise?
(Which I do not like either - isn't cond wait better for that?)


