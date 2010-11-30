From: Petr Rockai <prockai@redhat.com>
Date: Tue, 30 Nov 2010 12:12:47 +0100
Subject: [PATCH] Disable automatic MISSING_PV recovery when handles_missing_pvs is set (BZ 653643)
In-Reply-To: <20101129224015.GS29380@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Mon, 29 Nov 2010 22:40:15 +0000")
References: <87d3ptm965.fsf@twilight.int.mornfall.net.>
	<20101129224015.GS29380@agk-dp.fab.redhat.com>
Message-ID: <87hbezjc9c.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> On Thu, Nov 25, 2010 at 09:37:38PM +0100, Peter Rockai wrote:
>> it seems I did everything but actually posted the proposed patch for BZ
>> 653643. The explanation of what goes wrong where and how the patch fixes
>> that is in BZ comments.
>
> So what does the new output in the test case in that bz look like?
>
> Do we still get the last WARNING message?   (Where does it come from?
> Maybe it's too hard to fix that without removing it from other code
> paths where we do still want it?)

Which WARNING message you mean? There is only one in each command:
inconsistent metadata, we can't get rid of that one. About the PV not
found, I think it's better with the message than without. On the other
hand, we *could* make vgextend --restoremissing behave just like normal
vgextend if the PV is actually not part of the VG. But I think it's
better for scriptability (and predictability) to not do that.

Yours,
   Petr


