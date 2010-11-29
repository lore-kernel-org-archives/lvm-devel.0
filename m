From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 22:15:53 +0000
Subject: [PATCH] Refactor handling of percent values (towards BZ 654441)
In-Reply-To: <87aakxo6gn.fsf@twilight.int.mornfall.net.>
References: <87eia9o9b6.fsf@twilight.int.mornfall.net.>
	<87aakxo6gn.fsf@twilight.int.mornfall.net.>
Message-ID: <20101129221552.GR29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 02:53:12PM +0100, Peter Rockai wrote:
> and now an amended patch, taking Alasdair's IRC feedback into account. I
> have moved the implementation aside to a separate unit, and added a
> comment explaining how the percent_t type works.
 
Ack.  (Not checked line-by-line, but not spotted any problems in
a quick read through.)

What's our test coverage like for the code that uses and relies on
percentages?  - The parts that print them, and the parts like
detecting syncs are complete?
Any manual tests done or need doing?  I'd like to avoid regressions
in the 'mirroring complete' detection in particular.

Alasdair

> +percent_t make_percent(uint64_t numerator, uint64_t denominator)
> +{
> +    percent_t percent;
> +    if (!denominator)
> +        return PERCENT_100; /* FIXME? */

How does current code handle this, or does it never occur?
If not, just define it and state the behaviour in the header file (for example).
(or go for 'invalid')

Alasdair


