From: Petr Rockai <prockai@redhat.com>
Date: Tue, 10 May 2011 01:26:29 +0200
Subject: LVM2 tools/lvmcmdline.c liblvm/lvm_base.c lib/ ...
In-Reply-To: <20110507182412.GA9253@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Sat, 7 May 2011 19:24:13 +0100")
References: <20110507135019.1909.qmail@sourceware.org>
	<20110507182412.GA9253@agk-dp.fab.redhat.com>
Message-ID: <87iptje9qy.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> On Sat, May 07, 2011 at 01:50:19PM -0000, mornfall at sourceware.org wrote:
>> +	/* Set in/out stream buffering before glibc */
>
> Please add more explanatory comments inline.
>
> I mentioned this on IRC but there's been a trend towards not giving
> explanations inline which I'd like to see reversed.  Patch headers
> are becoming too long, containing information about the new version
> of the code which should instead have been placed inline.

I'd delegate this,

>> +  Avoid memlock size mismatch by preallocating stdio line buffers.

> If it fixed this, can't the temporary warning message suppression be
> removed now?

and this to Zden?k, since he's the author of the patch in question and
might therefore be better qualified to answer. Zden?k, if you'd prefer
to not deal with those, just bounce it back to me.

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


