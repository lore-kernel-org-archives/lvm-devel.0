From: Jim Meyering <jim@meyering.net>
Date: Mon, 06 Aug 2007 22:07:37 +0200
Subject: const correctness, first cut
In-Reply-To: <20070806193302.GK2064@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Mon\, 6 Aug 2007 20\:33\:02 +0100")
References: <87odhkd741.fsf@rho.meyering.net>
	<20070806193302.GK2064@agk.fab.redhat.com>
Message-ID: <87vebsbf5i.fsf@rho.meyering.net>
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
>
>>  		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
>> -				      &lvdisplay_full);
>> +				      (process_single_lv_fn_t)lvdisplay_full);
>
> Is there a nice way to avoid those casts?

This is where you wish for features of other languages.

I wrote an earlier iteration that instead added a new function,
process_each_lv_in_vg_ro (read-only), with the appropriate
signature for the fn-parameter, but IMHO, that was worse,
and besides, wasn't worth it, for just one use.


