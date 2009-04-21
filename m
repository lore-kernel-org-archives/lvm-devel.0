From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 21 Apr 2009 21:07:56 +0200
Subject: [PATCH 3/4] Udev integration: add cookie support for dmsetup
In-Reply-To: <1240338838.3705.63.camel@f10-node1>
References: <49DC978E.4040101@redhat.com> <1240338838.3705.63.camel@f10-node1>
Message-ID: <49EE198C.6070404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/21/2009 08:33 PM, Dave Wysochanski wrote:
>> -	if (!dm_task_run(dmt))
>> +	if (!dm_notification_sem_open(&cookie) ||
>> +			!dm_notification_sem_inc(cookie) ||
>> +			!dm_task_set_cookie(dmt, cookie))
>>  		goto out;
>>  
>> +	if (!dm_task_run(dmt)) {
>> +		dm_notification_sem_close(cookie);
>> +		goto out;
>> +	}
>> +
>> +	dm_notification_sem_wait_zero(cookie);
>> +	dm_notification_sem_close(cookie);
>> +
>>  	r = 1;
> 
> 
> This piece of code could exit without cleanup of the semaphore.  Should
> the first 'if' only check !dm_notification_sem_open, and the sem_inc and
> set_cookie be '||'d with dm_task_run in the second 'if'?

Oh, sure. I have to correct this. Thanks!

Peter


