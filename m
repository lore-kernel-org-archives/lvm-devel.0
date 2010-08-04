From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 4 Aug 2010 12:23:19 -0400
Subject: [PATCH] Handle transient errors for mirrored log in lvconvert --repair
In-Reply-To: <87pqy66p3c.fsf_-_@twilight.int.mornfall.net.>
References: <5C30BE7ED8B03E448B2E104602D4848A59228865AB@USINDEVS02.corp.hds.com>
	<87zkxa6xnl.fsf@twilight.int.mornfall.net.>
	<5C30BE7ED8B03E448B2E104602D4848A59228865B4@USINDEVS02.corp.hds.com>,
	<87pqy66p3c.fsf_-_@twilight.int.mornfall.net.>
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228865DF@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/29/10 15:54, Petr Rockai wrote:
> Takahiro Yasui <takahiro.yasui@hds.com> writes:
>> Yes, this solution is acceptable to me. As a long term, we can introduce
>> a kind of logic to keep the information of a bad segment or device and
>> extend cases for 'allocate' policy.
> great. I am attaching a patch proposal that would implement the outlined
> policy. I have tucked in a warning for a good measure.

>@@ -696,6 +703,13 @@ static int _lv_update_mirrored_log(struc
>@@ -705,12 +719,9 @@ static int _lv_update_mirrored_log(struc

I believe that two changes in _lv_update_mirror_log() are not for solving
this issue, and they are already checked in. :)

>@@ -1179,14 +1201,22 @@ static int _lvconvert_mirrors_repair(str
>+	if (log_lv)
>+		lv_check_transient(log_lv);
>+
>+	partial_count += _partial_lv_count(lv->vg);

If the log LV is not a mirrored log, we don't need to check the transient status.
I see that lv_check_transient() can handle both a disk log and a mirrored log
but checking its status as below reduces code steps to be executed.

+       if (log_lv && log_lv->status & MIRRORED)
+               lv_check_transient(log_lv);

Other than that, your patch looks OK to me.

Thanks,
Taka


