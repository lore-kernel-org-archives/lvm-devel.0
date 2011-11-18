From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 18 Nov 2011 21:48:45 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87obw9w6vv.fsf@aldalome.int.mornfall.net.>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
	<20111116130734.GE3294@agk-dp.fab.redhat.com>
	<87y5vdwydx.fsf@aldalome.int.mornfall.net.>
	<4EC6927B.4000402@redhat.com>
	<87obw9w6vv.fsf@aldalome.int.mornfall.net.>
Message-ID: <4EC6C4AD.9080702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.11.2011 20:46, Petr Rockai napsal(a):
> Zdenek Kabelac<zkabelac@redhat.com>  writes:
>
>> The formula above should be placed inside lvresize
>> (_adjust_policy_params()).
>
> And still completely besides the point.
>
>>> The problem:
>>>
>>> - to check whether anything needs to happen, lvextend needs to be
>>>     executed (this is *expensive*, even if it decides no action needs to
>>>     happen)
>>>
>>> - if nothing needed to happen, we don't need to call lvextend until the
>>>     utilisation has grown; *but* we don't know whether anything happened
>>>     (without ENO_ACTION_NEEDED that is)
>>
>> But you still call dmeventd_lvm2_run() - which is the most expensive
>> operation here - so I do not exactly see what do you actually safe here
>> i.e. if the resize will not happen because according to policy it's not
>> yet needed - then I do not see any difference ?
>
> Well, what can I say. I have already tried to explain how this works
> (twice?), and it's also quite obvious from the code. Well, once more: we
> do *not* call dmeventd_lvm2_run *if* the last lvconvert decided that
> nothing needs to be done *and* the snapshot utilisation did not change
> (more than 5%).
>
> To implement that, we need to: 1) know that snapshot utilisation grew
> (we know this already in the existing code) and 2) that lvconvert did
> not change anything. We don't know 2 and wrongly assume that nothing
> changes, ever (that's the bug).
>
> Were we to assume every time that lvconvert might have changed
> something, we would have to call it *every time* (every 10 seconds).
>
> Is it clear now?
>

Well my assumption is:

while  {
   read percentage
   if converted && current_percent < last_time_percent
         last_time_percent = current_percent
         converted = 0
   else if current_percent >= (last_time_percent + 5%)
	lvconvert
         converted = 1
   else
	wait 10sec
}


Zdenek


