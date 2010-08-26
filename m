From: Petr Rockai <prockai@redhat.com>
Date: Thu, 26 Aug 2010 14:35:45 +0200
Subject: [PATCH] Fix zombie mirror poll daemon (bug 585328)
In-Reply-To: <4C762334.8060403@redhat.com> (Milan Broz's message of "Thu, 26
	Aug 2010 10:17:56 +0200")
References: <1282772027.18079.3.camel@hydrogen.msp.redhat.com>
	<4C762334.8060403@redhat.com>
Message-ID: <87y6btblge.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:

> On 08/25/2010 11:33 PM, Jonathan Brassow wrote:
>> -	if (!lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
>> +	if (!(lv->status & MIRRORED) ||
>> +	    !lv_mirror_percent(cmd, lv, !parms->interval, &segment_percent,
>>  			       &percent_range, &event_nr) ||
>>  	    (percent_range == PERCENT_INVALID)) {
>>  		log_error("ABORTING: Mirror percentage check failed.");
>
> why not move this check inside lv_mirror_percent?
> (or is this only place where the bug can appear?)

I think it's actually safer to fix this here at this point in
time. Otherwise, lv_mirror_percent could start failing unexpectedly on
some mis-behaving code and introduce new bugs.

> (and it should probably use !lv_is_mirrored(lv) instead of mask)
Indeed. Please fix.

I would personally also change the code to print a different error if
the mirror is no longer a mirror, which would be likely less confusing
to the user.

Anyway, assuming the lv_is_mirrored change, OK.

Reviewed-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


