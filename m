From: Milan Broz <mbroz@redhat.com>
Date: Tue, 18 Oct 2011 14:56:00 +0200
Subject: [PATCH] Avoid recursive calls from dmeventd to itself
In-Reply-To: <87y5wsq5l9.fsf@aldalome.int.mornfall.net.>
References: <8739gh3w98.fsf@aldalome.int.mornfall.net.>
	<20110901194235.GA4025@agk-dp.fab.redhat.com>
	<87ippb2jne.fsf@aldalome.int.mornfall.net.>
	<87y5wsq5l9.fsf@aldalome.int.mornfall.net.>
Message-ID: <4E9D7760.6050400@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/10/2011 04:33 PM, Petr Rockai wrote:
> Petr Rockai <prockai@redhat.com> writes:
> 
>>> It might be a little more code, but I'd rather see it a property of the handle
>>> never to perform dmeventd monitoring calls.  We never fixed handle init to 
>>> take multiple settings, so maybe call
>>>   void lvm2_disable_dmeventd_monitoring(void *handle)
>>> after handle initialisation to set DMEVENTD_MONITOR_DISABLED and have that take
>>> precedence over any later attempt to enable monitoring.
>>
>> This sounds like a better option. Now that raises the question why we
>> aren't doing the same thing for memlock_{inc,dec}? We should certainly
>> unify these two things. I'll have a look, and unless I run into a
>> stumbling block will submit a patch to do that.
> 
> The patch doing that is attached. Seems straightforward enough to me. We
> can change the memlock interface to be the same, too.

ack.

Milan


