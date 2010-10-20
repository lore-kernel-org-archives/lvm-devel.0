From: Petr Rockai <prockai@redhat.com>
Date: Wed, 20 Oct 2010 15:03:04 +0200
Subject: [PATCH] (DRAFT!) Fix a deadlock in CLVMD (possibly related to BZ 561226).
In-Reply-To: <4CBEC730.4020906@redhat.com> (Milan Broz's message of "Wed, 20
	Oct 2010 12:40:48 +0200")
References: <874ocje7y1.fsf@twilight.int.mornfall.net.>
	<4CBEC730.4020906@redhat.com>
Message-ID: <87wrpd9fuf.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:

> p.s.
> nitpicking
>
> 	DEBUGLOG("in sub thread: client = %p\n", client);
> 	+ pthread_mutex_lock(&client->bits.localsock.mutex);
>
> 	/* Don't start until the LVM thread is ready */
> 	pthread_mutex_lock(&lvm_start_mutex);
> 	pthread_mutex_unlock(&lvm_start_mutex);
> 	DEBUGLOG("Sub thread ready for work.\n");
>
>
> Can we move that localsock.muext lock after the lvm_start_mutex exercise?
> (Which I do not like either - isn't cond wait better for that?)

I would be actually wary about that -- I suspect that going the other
way around could introduce a (very slight) race condition. Not that it
would ever happen in practice, but still. On the other hand, I didn't
try too hard to think about it, so I might be wrong.

Yours,
   Petr.


