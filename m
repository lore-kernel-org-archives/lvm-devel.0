From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 18 Nov 2011 18:14:35 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87y5vdwydx.fsf@aldalome.int.mornfall.net.>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
	<20111116130734.GE3294@agk-dp.fab.redhat.com>
	<87y5vdwydx.fsf@aldalome.int.mornfall.net.>
Message-ID: <4EC6927B.4000402@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.11.2011 10:52, Petr Rockai napsal(a):
> Hi,
>
> Alasdair G Kergon<agk@redhat.com>  writes:
>
>>     (new_size = old_size + amount_to_extend_by)>
>> 	old_size_in_use + ((100 + autoextend_percent) - autoextend_threshold) / (100+autoextend_percent) * (old_size + amount_to_extend_by)
>>
>> IOW we scale the parameters based on the amount currently in use.
>>
>> For example:
>>
>>      snapshot_autoextend_threshold = 70
>>      snapshot_autoextend_percent = 20
>
> [snip] This is all great, but completely besides the point. So let me
> stress the point once more:
>
> - snapshot DSO monitors a snapshot, getting its status line every 10
>    seconds or so
> - the DSO has *no access* to the policy variables, because it does not
>    (and can not) read lvm.conf

The formula above should be placed inside lvresize (_adjust_policy_params()).

It's advantage was to resize in a way - the it should avoid the need of
quick subsequent (i.e. more then autoextend_percent - so if you fill
snapshot very fast, there should be some reserve to catch up within
next 10s check.

> The problem:
>
> - to check whether anything needs to happen, lvextend needs to be
>    executed (this is *expensive*, even if it decides no action needs to
>    happen)
>
> - if nothing needed to happen, we don't need to call lvextend until the
>    utilisation has grown; *but* we don't know whether anything happened
>    (without ENO_ACTION_NEEDED that is)

But you still call dmeventd_lvm2_run() - which is the most expensive
operation here - so I do not exactly see what do you actually safe here
i.e. if the resize will not happen because according to policy it's not
yet needed - then I do not see any difference ?

Zdenek


