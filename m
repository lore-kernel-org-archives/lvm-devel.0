From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 14 Aug 2010 17:48:29 -0000
Subject: [Bug 16588] Regression introduced in 2.6.35.2 causes freezing, crashing, oopsing
In-Reply-To: <201008141736.o7EHa1ui024187@demeter.kernel.org>
References: <bug-16588-5873@https.bugzilla.kernel.org/>
	<201008141736.o7EHa1ui024187@demeter.kernel.org>
Message-ID: <AANLkTimXGb6-fFORR=Vm6gcdST6Sv3Uvsie7VZbEh2ev@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Aug 14, 2010 at 10:36 AM,  <bugzilla-daemon@bugzilla.kernel.org> wrote:
>-
> I did a git bisect run and it pointed this commit as the first bad one. Indeed,
> if I revert it (after fixing trivial conflicts due to commit
> 3aba3fa070fc0f38de2d41252aee), the error doesn't occur.

Hmm. Turning those "Maps lock" numbers into hex gives us

  "Internal error: Maps lock 0xdbd000 < unlock 0xdbe000"

which is a bit suggestive - it's "page aligned". I wonder if the
"Maps" part refers to /proc/self/maps, and the process reads its own
maps file to see where the segments are.

The whole (and only) point of the whole stack guard page patch is to
make sure that a grow-down stack segment always has a guard page as
it's lowest page. And that guard page obviously means that the stack
segment is now one page bigger (downwards). If the lvcreate binary for
some reason looks at how big its virtual mappings are, and assumes
that they must be some particular size, then that would explain the
error message.

I wonder who knows. I'm cc'ing lvm-devel@redhat.com on this email, to
see if I can reach somebody who knows that that "Internal error"
means.

                             Linus


