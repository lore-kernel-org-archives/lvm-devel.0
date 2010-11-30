From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Nov 2010 11:21:53 +0100
Subject: [Bug 16588] Regression introduced in 2.6.35.2 causes freezing, crashing, oopsing
In-Reply-To: <AANLkTimXGb6-fFORR=Vm6gcdST6Sv3Uvsie7VZbEh2ev@mail.gmail.com>
References: <bug-16588-5873@https.bugzilla.kernel.org/>	<201008141736.o7EHa1ui024187@demeter.kernel.org>
	<AANLkTimXGb6-fFORR=Vm6gcdST6Sv3Uvsie7VZbEh2ev@mail.gmail.com>
Message-ID: <4CF4D041.6090902@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.8.2010 19:47, Linus Torvalds napsal(a):
> On Sat, Aug 14, 2010 at 10:36 AM,  <bugzilla-daemon@bugzilla.kernel.org> wrote:
>> -
>> I did a git bisect run and it pointed this commit as the first bad one. Indeed,
>> if I revert it (after fixing trivial conflicts due to commit
>> 3aba3fa070fc0f38de2d41252aee), the error doesn't occur.
> 
> Hmm. Turning those "Maps lock" numbers into hex gives us
> 
>   "Internal error: Maps lock 0xdbd000 < unlock 0xdbe000"
> 
> which is a bit suggestive - it's "page aligned". I wonder if the
> "Maps" part refers to /proc/self/maps, and the process reads its own
> maps file to see where the segments are.
> 
> The whole (and only) point of the whole stack guard page patch is to
> make sure that a grow-down stack segment always has a guard page as
> it's lowest page. And that guard page obviously means that the stack
> segment is now one page bigger (downwards). If the lvcreate binary for
> some reason looks at how big its virtual mappings are, and assumes
> that they must be some particular size, then that would explain the
> error message.
> 
> I wonder who knows. I'm cc'ing lvm-devel at redhat.com on this email, to
> see if I can reach somebody who knows that that "Internal error"
> means.

LVM is doing it's 'own' version of  mlockall() functionality.
(mainly to avoid locking 100MB locales files which is used on same
distributions (like Fedora) to speedup setlocale() functionality.)

Internal Error here means - LVM failed to avoid allocation which would require
to increase the heap size (lvm is preallocating some memory to have some
'spare' room) and tried to allocate some extra space during 'memory locked'
state - this is an internal error - which is usually mostly harmless - but in
the case there would be high memory pressure - lvm can fail to get this extra
memory and deadlock the system (in the case it would suspend some root/swap
devices) (check basically sums locked and unlocked memory - which is not the
best we could - but seems sufficient - numbers should be equal).

With the stack-guard fix patch and it's backport to older kernels - there was
a missing patch (see https://bugzilla.redhat.com/show_bug.cgi?id=643500) -
I've posted this on lkml list - unsure whether backporting was properly done.

Anyway - the new version of LVM (>= 2.02.75) code does read this maps file in
one read operation and just after that it's doing memory locking:
http://www.redhat.com/archives/lvm-devel/2010-September/msg00091.html
(With stackguard patch  maps list is modified during read).

Zdenek



