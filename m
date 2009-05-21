From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 21 May 2009 08:26:03 -0500
Subject: [PATCH] Use lvconvert --repair as a dmeventd mirror failure handler
In-Reply-To: <87my96q0k0.fsf@mornfall.net>
References: <87r5ylbphy.fsf@mornfall.net>
	<64033B0F-38A8-4E13-BDD6-DAFEA17C4C51@redhat.com>
	<87my96q0k0.fsf@mornfall.net>
Message-ID: <999B59FD-7D31-48F8-B286-BAE8E097F25E@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On May 21, 2009, at 4:15 AM, Petr Rockai wrote:

> Jonathan Brassow <jbrassow@redhat.com> writes:
>> Wait, what?  Are you saying that with this change, it /will/ find  
>> space for a
>> new mirror leg?  It doesn't do that now.  I also don't  think  
>> lvrepair is the
>> right place to have the allocation take place.   'lvrepair' should  
>> do exactly
>> that - repair.  From there, you could do  an lvconvert.  The mirror  
>> DSO should
>> do the 'lvconvert' portion based  on user set policy found in /etc/ 
>> lvm/lvm.conf
>> -- see  'mirror_log_fault_policy' and 'mirror device_fault_policy'.
>>
>> Am I missing something?
>
> Yes, the current policy is completely bogus. It will kill LVs that are
> completely unrelated to the mirror in question (if they happen to  
> have any
> extents allocated in any currently missing PV, which may be even  
> unrelated to
> the one that caused the mirror failure). Moreover, I don't know what  
> you mean
> with "lvrepair" since there's no such thing. And lvconvert --repair  
> does
> exactly repair, by either removing (no parallel space available) or  
> replacing
> (free parallel space available) missing devices.
>
> The mirror_log_fault_policy and device_fault_policy is all cool, but  
> it's not
> implemented (even the fact it's in lvm.conf while there's no code to  
> handle the
> options is quite silly). So I expect that an --auto switch will need  
> to be
> added to lvconvert --repair, that will honour those two  
> configuration options.
>
> Please also note that this could have been fixed months ago (the  
> patches have
> been in review since last July at least -- see eg. message-id
> <87tze8244p.fsf@eriador.mornfall.net>). Please next time, if you  
> know all along
> that a policy change is not acceptable, take a few minutes and reply  
> to the
> proposed patch. Thanks!
>
> (Just as a rationale, I did not implement the current lvm.conf  
> options simply
> because it has been suggested, that a much more complex  
> configuration using
> tags is planned. It just seemed redundant to implement options that  
> would
> become deprecated in the next release. Unfortunately, no-one has  
> pointed out
> that they need to be, or why.)
>
> As for doing things directly in the mirror DSO (as compared to  
> lvconvert
> --repair), it would get much more complicated, implementation-wise.  
> It would
> also lead to lots of code duplication (and the theoretical advantage  
> of having
> the code separated is dubious, too).

Of course the current policy is bogus.  Forgive my typo, s/lvrepair/ 
lvconvert --repair/.

I guess the thing I care most about is that we are switching from a  
policy of "just remove the failed device" to "just replace the device  
(if possible)".  The methods you are using to repair are far superior  
to what we had (addresses the "bogus" part in the current  
implementation).  However, I don't understand why we are now  
automatically taking the next step.  If we allow for user  
specification of policy - then why not wait for that before taking  
action to replace the device?  Otherwise we could be flip-flopping on  
the (default) policy.

  brassow
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090521/e6b228e6/attachment.htm>
