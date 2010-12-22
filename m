From: Petr Rockai <prockai@redhat.com>
Date: Wed, 22 Dec 2010 10:35:45 +0100
Subject: [PATCH 19/23] Warning - dead code problem elimination
In-Reply-To: <4D10EA2E.8080404@redhat.com> (Milan Broz's message of "Tue, 21
	Dec 2010 18:55:58 +0100")
References: <cover.1292945707.git.zkabelac@redhat.com>
	<2e3abc21f31d172f75c96f74e483dfbee6d9dd07.1292945707.git.zkabelac@redhat.com>
	<4D10EA2E.8080404@redhat.com>
Message-ID: <87mxny2lqm.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:

> On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
>> @@ -653,8 +653,7 @@ static int _event_wait(struct thread_status *thread, struct dm_task **task)
>>  	if (dm_task_run(dmt)) {
>>  		thread->current_events |= DM_EVENT_DEVICE_ERROR;
>>  		ret = DM_WAIT_INTR;
>> -
>> -		if ((ret = dm_task_get_info(dmt, &info)))
>> +		if (dm_task_get_info(dmt, &info))
>>  			thread->event_nr = info.event_nr;
>>  	} else if (thread->events & DM_EVENT_TIMEOUT && errno == EINTR) {
>>  		thread->current_events |= DM_EVENT_TIMEOUT;
>
> #define DM_WAIT_RETRY 0
> #define DM_WAIT_INTR 1
>
> dm_task_get_info returns 0/1 - it is probably intended such way?
>
> I think you should return DM_WAIT_RETRY if info fails then (so the code _was_ correct)?
>
> mornfall? :)

Jeez, I wish I knew! I don't think I wrote this code. Anyway, it would
make sense to add ret = DM_WAIT_RETRY in the else branch (i.e. get_info
fails). Not that this is likely to ever trigger...

Petr


