From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Thu, 29 Jul 2010 14:07:51 -0400
Subject: Handle transient errors for mirrored log in lvconvert --repair
In-Reply-To: <87zkxa6xnl.fsf@twilight.int.mornfall.net.>
References: <5C30BE7ED8B03E448B2E104602D4848A59228865AB@USINDEVS02.corp.hds.com>,
	<87zkxa6xnl.fsf@twilight.int.mornfall.net.>
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228865B4@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

On 07/29/10 12:49, Petr Rockai wrote:
> Takahiro Yasui <takahiro.yasui@hds.com> writes:
>> As shown above, I hope this kind of code to be added to check the status
>> of a log volume.
> 
> [snip]
> 
>> I understand your concern that this doesn't cover all cases. For example,
>> there might be a problem when mirror_{log|mirror}_fault_policy is set
>> to 'allocate' instead of 'removed.'
> 
>> Here is a discussion. We can rescue a case that 'removed' policy is set to
>> mirror_{log|mirror}_fault_policy by adding lv_check_transient() for a mirrored
>> log volume, while application will hang up when a transient error or medium
>> error occurred on mirrored log without this patch.
> 
>> How about adding the patch for a short term solution to save in the case of
>> 'removed' policy? We have already made a decision when the first patch is
>> committed.
> 
> I think the main concern is that a sync over a partially failing PV will
> make things a lot worse. On the other hand, I agree that having multiple
> failing devices is a rare situation. I would concede to the following:
> 
> If a transient error is detected, repair the mirror as usual through
> down-conversion, but refuse to do any allocation. This is the same
> situation as when there are no spare PVs available. This is a
> conservative over-approximation that is always correct. We are issuing a
> log_warn that the mirror could not be restored to its previous state,
> which should end up in syslog. From there, this is a matter of the
> sysadmin to take action. The mirror should keep operating in a reduced
> mode in the meantime.
> 
> If this was noted in documentation, I think this would be appropriate
> for RHEL6. The check wouldn't be very hard to do, I believe: Count the
> number of partial LVs in the VG before the transient check and count
> again after, if the numbers differ, forbid any new allocations.

Your idea sounds good to me. The 'remove' policy should always work, but
the 'allocate' policy can be optional. It means that it should work only
when it satisfies requirements. (e.g. there are enough spare disks, the
number of non-partial volumes which is counted before the transient check
is the same as the count after the transient check, etc)

> Would you find such a solution acceptable? Overall, it in the case of a
> transient failure, it will work as if "remove" was specified regardless
> of actual lvm.conf setting. For permanent failures, the policy is
> respected as previously.

Yes, this solution is acceptable to me. As a long term, we can introduce
a kind of logic to keep the information of a bad segment or device and
extend cases for 'allocate' policy.

Thanks,
Taka


