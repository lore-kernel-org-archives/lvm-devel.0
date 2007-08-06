From: Jim Meyering <jim@meyering.net>
Date: Mon, 06 Aug 2007 23:09:10 +0200
Subject: const correctness, first cut
In-Reply-To: <87hcnccr5q.fsf@eriador.mornfall.net> (Petr Rockai's message of
	"Mon\, 06 Aug 2007 23\:02\:57 +0200")
References: <87odhkd741.fsf@rho.meyering.net>
	<20070806193302.GK2064@agk.fab.redhat.com>
	<87vebsbf5i.fsf@rho.meyering.net>
	<87hcnccr5q.fsf@eriador.mornfall.net>
Message-ID: <87k5s8bcax.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> wrote:
>>>>  		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
>>>> -				      &lvdisplay_full);
>>>> +				      (process_single_lv_fn_t)lvdisplay_full);
>>>
>>> Is there a nice way to avoid those casts?
>>
>> This is where you wish for features of other languages.
>>
>> I wrote an earlier iteration that instead added a new function,
>> process_each_lv_in_vg_ro (read-only), with the appropriate
>> signature for the fn-parameter, but IMHO, that was worse,
>> and besides, wasn't worth it, for just one use.
>
> You could still add a new function that just confines the ugly cast?
> (Assuming that's not what you have done). Maybe _const instead of _ro,
> too.

That's what I did.
But *it* then has to call the original, process_each_lv_in_vg_ro,
and in so doing, it needs its own casts, in addition to the
added layer of indirection.

Adding one little cast (per call) is not pretty, but less ugly
than the alternative, since there's only one use of each.


