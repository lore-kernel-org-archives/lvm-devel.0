From: Petr Rockai <prockai@redhat.com>
Date: Mon, 18 Oct 2010 21:54:44 +0200
Subject: [PATCH] (DRAFT!) Fix a deadlock in CLVMD (possibly related to BZ 561226).
In-Reply-To: <874ocje7y1.fsf@twilight.int.mornfall.net.> (Petr Rockai's
	message of "Mon, 18 Oct 2010 19:17:58 +0200")
References: <874ocje7y1.fsf@twilight.int.mornfall.net.>
Message-ID: <87y69vcm4b.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> writes:
> (It is also recommended that the reviewer spends a while reading
> pthread_cond_wait manpage, especially the section about the mutex
> pointer, and also with a paper and pencil sketching on how things
> could go wrong if the mutex is used incorrectly, as in this case.)

I can try to illustrate the problem in ASCII art... There is a single
mutex around (L for Lock, U for Unlock), a signal (S) and a wait (W). C
for pthread_create. Time flows from left to right, each arrow is a
thread.

So first the "naive" scenario, with no mutex (PPT = pre_and_post_thread,
MCT = main clvmd thread). I will also use X, for a moment when MCT
actually waits for something to happen that PPT was supposed to do.


MCT -----C ------S--X-----S----X----------------------S------XXXXXXXXX
         |                everything OK up to this --> <-- point...
PPT       -----WWW-----WWWW------------------------------WWWWWWWWWWWWW

Ok, so pthread API actually does not let you use W/S like that. It goes
out of its way to tell you that you need a mutex to protect the W so
that the above cannot happen. *But* if you get creative and just lock
around the W's and S's, this happens:

MCT ----C-----LSU----X-----LSU----X------------LSU------XXXXXXX
        |
PPT      ---LWWWU-------LWWWWU-----------------------LWWWWWWWWW

Ooops. Nothing changed (the above is what actually was done by clvmd
before the patch). So let's do it differently, holding L locked *all*
the time in PPT, unless we are actually in W (this is something that the
pthread API does itself, see the man page).

MCT ----C-----LSU------X---LSU---X-----LLLLLLLSU----X----
        |                             (and they live happily ever after)
PPT     L---WWWWW---------WWWW----------------W----------

So W actually ensures that L is unlocked *atomically* together with
entering the wait. That means that unless PPT is actually waiting, it
cannot be signalled by MCT. So if MCT happens to signal it too soon (it
wasn't waiting yet), it MCT will be blocked on the mutex (L), until PPT
is actually ready to do something.

That's the story. You obviously need monotype-capable reader to make any
sense of it. : - )

Yours,
   Petr.


