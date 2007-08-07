From: Jim Meyering <jim@meyering.net>
Date: Tue, 07 Aug 2007 11:11:12 +0200
Subject: const correctness, first cut
In-Reply-To: <20070806193302.GK2064@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Mon\, 6 Aug 2007 20\:33\:02 +0100")
References: <87odhkd741.fsf@rho.meyering.net>
	<20070806193302.GK2064@agk.fab.redhat.com>
Message-ID: <87wsw7aevj.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Mon, Aug 06, 2007 at 05:18:22PM +0200, Jim Meyering wrote:
>> I find it easier to read code that uses "const" whenever possible.
>
> All looks sane, thanks.

Thanks for the review.
I committed that, along with const-adding changes to btree.[ch].

The sole cast I added there (in _lookup) is unavoidable, given
a const-correct interface.  It's analogous to the strstr case,
where the signature forces you to return char*, yet the pointer
you actually return is offset from the "const char *" parameter.


