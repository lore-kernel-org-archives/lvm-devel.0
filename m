From: Peter Rajnoha <prajnoha@redhat.com>
Date: Sat, 10 Oct 2009 21:42:41 +0200
Subject: Usage of sysV semaphores
In-Reply-To: <20091010091654.GA26029@wavehammer.waldi.eu.org>
References: <20091010091654.GA26029@wavehammer.waldi.eu.org>
Message-ID: <4AD0E3B1.3040305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

On 10/10/2009 11:16 AM, Bastian Blank wrote:
> It uses a 32 bit value to synchronize itself. This value needs to make
> two things possible: find our own values and distiguish between them.
> - Find our own values
>   This is done by a 16 bit magic, so a truly random value have a 1/2**16
>   probability to reach the dm namespace. This is not good but okay.
> - Distiguish between them
>   Because of the birthday paradox the probability of conflicting values
>   becomes 0.5 with only 2**8 concurent events. Peter spoke about
>   hundreds or even thousands of possible flying events, so this is
>   relevant and will produce busy looping to find a free one.

...you should also consider that we use just one semaphore per dm tree,
so the number of events that we are awaiting is not always equal to the
number of semaphores set. It's less in some situations (e.g. mirrors,
snapshots...).

But ok, I'm taking into consideration your concerns... Maybe we can think
of trying to reuse one semaphore per lvm command in places where we loop
over all LVs in one VG (e.g. "vgchange -ay <vgname>" and like). But is this
really needed? Even if we activate a lot of devices at once (or remove),
like in activating/deactivating a VG with many LVs, we set one semaphore,
wait for the notification (for that one LV) and if the notification comes,
we remove the semaphore and then repeat this sequence for all the other
LVs...

> SysV semaphore operations are not interruptible. So if something goes
> wrong, and according to Murphy it will, the user is left with a process
> that can only be killed by SIGKILL and is then not able to clean up
> after itself. I'm not sure why, but this was one of the first things
> that happened to me during testing.

...not quite. We've addedd "dmsetup udevcomplete_all" for such disastrous
scenario -- this one will remove all existing semaphores with that
DM_COOKIE_MAGIC prefix. The code that waits then catches semaphore removal
event and will continue and finish the operation.

But we tried to minimise the possibility of such hangs. If the old kernel
is used, then the udev_sync code is switched off completely! Also, if
udev is not running, it is switched off as well. If the hang occurs and
you have the kernel running OK (so DM_COOKIE is delivered right to
userspace) and udevd itself is OK, then the only thing that could be
the cause of the problem are udev rules which could pose delays...

I've spent considerable time searching for possible uses in all possible
udev rules (at least the ones we have in Fedora distro). When I tested
the code myself for the first time, the first thing I got was a 3 second
delay when working with devices. Finally we found out it was a misbehaving
foreign rule... which called a sleep within a udev rule :) Since one of the
last udev rules called is the dm notification rule, you could end up with
delays if someone somewhere deep in the rules does something nasty. And
it happens -- at least you can see why am I so suspicious and paranoic
when dealing with udev rule design (so it also explains why am I not afraid
to use OPTIONS+="last_rule" for temporary cryptsetup devices as an example).

> SysV semaphores are a restricted ressource because they are not cleaned
> up upon process exit. So random devmapper usage can just fail with a
> message about a, from the user view, completely unrelated ressource.

..but POSIX semaphores don't have waiting for zero, at least not so direct
as with SysV ones. And this is what we really need. Also, I really want to
avoid using any complex synchronisation mechanisms which could give a reason
for very painful bugs that are hard to track and debug. The solution we have
is simple enough. Yes, there's a possibility that the notification will get
lost but if it does, then something is really wrong and needs a real inspection!

But, really, if you have any ideas how to enhance this in a way that it
remains simple enough (minimising the possibility of future bugs and any
pain in maintaining it) and giving it even more reliability, then I'm really
open to it...

Anyway, thanks for looking into this! Any ideas are welcome!

Peter


