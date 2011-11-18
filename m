From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 18 Nov 2011 11:11:11 -0600
Subject: [PATCH - v2] LVM: New flag, LV_REBUILD
In-Reply-To: <545B0B19-4FAA-46C9-8C16-48AB490274BD@redhat.com>
References: <1320963969.7209.1.camel@f14.redhat.com>
	<1321293985.6418.0.camel@f14.redhat.com>
	<4EC417C4.8060707@redhat.com>
	<545B0B19-4FAA-46C9-8C16-48AB490274BD@redhat.com>
Message-ID: <4A1A2F14-071E-4BB2-9BE5-5D23F89CC85A@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Nov 18, 2011, at 10:05 AM, Jonathan Brassow wrote:

> 
> On Nov 16, 2011, at 2:06 PM, Zdenek Kabelac wrote:
> 
>> Dne 14.11.2011 19:06, Jonathan Brassow napsal(a):
>>> Changes from previous:
>>> - New rebuild flag is now written to on-disk LVM metadata
>>> - An additional metadata write/commit is necessary to clear the flag
>>> after a proper resume
>>> - flags.c file updated
>>> 
>>> brassow
>>> 
>>> Add new flag, LV_REBUILD.
>>> 
>>> Until now, I had been using the LV_NOTSYNCED as a flag to indicate that RAID
>>> sub-LVs needed to be rebuilt.  (The 'rebuild' parameter is then specified in
>>> the DM CTR table.)  However, I don't want to use a flag that gets written to
>>> the LVM metadata... and the LV_NOTSYNCED flag's original meaning does not
>>> suite the purpose adequately.
>>> 
>>> This patch proposes and uses a new flag, LV_REBUILD.
>> 
>> Hmm so now - when it's written to disk - it looks like  LV_REBUILD and LV_NOTSYNCED is mostly the same meaning - except  one is used in raid
>> and original in mirror ?
>> 
>> So I think it's easier to keep just one flag ?
>> (Well the bit field space is somewhat limited)
> 
> Perhaps.  I've considered this and certainly it'd be easy for me to leave things the way they are.  However, LV_NOTSYNCED means that the LV was created (or extended) with '--nosync', and signifies that it has not and will not undergo a complete synchronization.  LV_REBUILD, on the other hand, means precisely the opposite - the LV is to undergo a complete synchronization now.  LV_NOTSYNCED signifies an attribute of the LV, while LV_REBUILD signifies an action that needs to be taken.
> 
> The only reason the difference is not more obvious is because you can look at 'LV_NOTSYNCED' sideways and sort-of make it work.  "These sub-LVs are not in-sync right now, and must be made to be in-sync." - or some similar thinking could get you there.
> 
> I'm good either way, but I'd prefer the new flag...

Now that I think a little more on it, I'm becoming even more in favor of the separate flag.

Consider the case we discussed earlier, where the machine dies after the vg_commit but before the resume.  This leaves the 'rebuild' DM table argument yet to be supplied to the kernel in order to clear the device's bitmap.  When the machine comes up and it is required to clean-up the flags after activation, it would complicate the process to force the code to know when the LV_NOTSYNCED flag means that the LV was not synced and to leave the flag, or whether it means the LV needs to be synced/rebuilt and the flag must be cleared.

 brassow



