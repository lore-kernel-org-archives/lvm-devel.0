From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 29 Jun 2015 17:01:07 +0200
Subject: udev cookie on DM_DEVICE_RELOAD
In-Reply-To: <55915CB6.9070407@suse.de>
References: <55914C1C.6050309@suse.de> <20150629140220.GA1604@redhat.com>
	<55915B15.708@redhat.com> <55915CB6.9070407@suse.de>
Message-ID: <55915DB3.7060802@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/29/2015 04:56 PM, Hannes Reinecke wrote:
> On 06/29/2015 04:49 PM, Peter Rajnoha wrote:
> [ .. ]
>>
>> Actually, we don't check proper combination of dm_task_set_cookie with
>> dm task type. So currently, if someone sets cookie on a task that does
>> not produce uevents, it can hang if dm_udev_wait is called for such cookie.
>>
>> I've noticed we have a FIXME in the code for this already, but clearly
>> nobody has run into this issue yet. I'll add the check!
>>
>> As for the DM_DEVICE_RELOAD - yes, it needs DM_DEVICE_RESUME to be called
>> right after the reload for the new table to be used (and hence the uevent
>> with the cookie generated as well). If you call RELOAD, the inactive
>> table is loaded which is then switched to active with the RESUME.
>>
>> The task that is transparently translated into 3 tasks internally is the
>> DM_DEVICE_CREATE (with table) which translates into CREATE + LOAD + RESUME.
>>
>> Anyway, yes, the check whether cookie is not misused is not there yet, so
>> that's why you hit this.
>>
> So how to circumvent this?
> Should I do an explicit
> SUSPEND/RELOAD/RESUME call sequence and add a cookie on the final
> resume?
> Or is it sufficient to call RESUME after RELOAD without suspending
> first? Or another magic trick?

suspend -> reload -> dm_task_set_cookie -> resume -> dm_udev_wait
should be the proper sequence.

The reload never translates internally into more tasks...
Can you point me to the exact code you're trying to edit?

-- 
Peter


