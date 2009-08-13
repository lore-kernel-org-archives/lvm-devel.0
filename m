From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 13 Aug 2009 21:46:06 +0100
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <87fxbvub60.fsf@twilight.int.mornfall.net.>
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
	<20090812223551.GQ7033@agk-dp.fab.redhat.com>
	<87fxbvub60.fsf@twilight.int.mornfall.net.>
Message-ID: <20090813204606.GU7033@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 13, 2009 at 02:54:15PM +0200, Peter Rockai wrote:
> Alasdair G Kergon <agk@redhat.com> writes:
> > Add a comment to show what the result of this code is.
> > "aux_" is a decent idea for the prefix: any other ideas?
> > Something based on 'waiting' or 'queue'?
> > Best might be a suffix on the existing name, with a separator
> > character that cannot appear in a VG name.
> >    V_vg1:queue
> > Then a sorted 'ls' will list them adacently.
> I have thought about that at first (it was actually easier to implement), but I
> decided against because it feels fragile. So unless you think it's worth it,
> I'd stick with the prefix solution, which is I think quite foolproof.

What is it that feels 'fragile'?

When debugging a problem, listing all the locks with 'ls' (or lsof/grep/sort)
and finding them paired up nicely is a definite advantage.

The namespace for VGs and LVs is well-defined.  (By contrast, the PV namespace
is poorly-defined and still causes problems.)

Alasdair


