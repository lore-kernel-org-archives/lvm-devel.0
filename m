From: Petr Rockai <prockai@redhat.com>
Date: Mon, 06 Aug 2007 23:02:57 +0200
Subject: const correctness, first cut
In-Reply-To: <87vebsbf5i.fsf@rho.meyering.net> (Jim Meyering's message of
	"Mon, 06 Aug 2007 22:07:37 +0200")
References: <87odhkd741.fsf@rho.meyering.net>
	<20070806193302.GK2064@agk.fab.redhat.com>
	<87vebsbf5i.fsf@rho.meyering.net>
Message-ID: <87hcnccr5q.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>>>  		process_each_lv_in_vg(cmd, vg, NULL, NULL, NULL,
>>> -				      &lvdisplay_full);
>>> +				      (process_single_lv_fn_t)lvdisplay_full);
>>
>> Is there a nice way to avoid those casts?
>
> This is where you wish for features of other languages.
>
> I wrote an earlier iteration that instead added a new function,
> process_each_lv_in_vg_ro (read-only), with the appropriate
> signature for the fn-parameter, but IMHO, that was worse,
> and besides, wasn't worth it, for just one use.

You could still add a new function that just confines the ugly cast?
(Assuming that's not what you have done). Maybe _const instead of _ro,
too.

Yours, Peter.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


