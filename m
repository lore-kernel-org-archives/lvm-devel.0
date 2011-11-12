From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 11 Nov 2011 18:12:12 -0600
Subject: [PATCH] LVM: New flag, LV_REBUILD
In-Reply-To: <4EBD4BEE.2050301@redhat.com>
References: <1320963969.7209.1.camel@f14.redhat.com>
	<4EBD4BEE.2050301@redhat.com>
Message-ID: <004F51D6-5E4B-4320-977B-5097A83C6A67@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Nov 11, 2011, at 10:23 AM, Zdenek Kabelac wrote:

> Dne 10.11.2011 23:26, Jonathan Brassow napsal(a):
>> Any objections to a new flag?
>> 
>> brassow
>> 
>> Add new flag, LV_REBUILD.
>> 
>> Until now, I had been using the LV_NOTSYNCED as a flag to indicate that RAID
>> sub-LVs needed to be rebuilt.  (The 'rebuild' parameter is then specified in
>> the DM CTR table.)  However, I don't want to use a flag that gets written to
>> the LVM metadata... and the LV_NOTSYNCED flag's original meaning does not
>> suite the purpose adequately.
>> 
>> This patch proposes and uses a new flag, LV_REBUILD.
> 
> Hmm and how is this going to work in some crash scenarios - are you always
> able to deduce the raid was not yet build ?
> 
> Also it seems we encode each flag into lib/format_text/flags.c

Thanks for looking over the patches.  You are right.  If the flag is not permanent, the machine could fail after the vg_commit, but before the resume - resulting in the devices never being rebuilt.

The problem from the other side is that if the flag is permanent (is written to metadata), then the machine could crash after the resume has properly prep'ed the device for a rebuild but before clearing the flag for the next activation.  This would result in the devices being rebuilt every time the LV is activated.

Perhaps I will work on some post processing for lvchange/vgchange, where certain flags are cleared after activation has been assured.  Or perhaps a flag could be added to the VG on-disk metadata that would indicate transaction has failed part-way through.

I heard thinp is using generation numbers to allow the kernel to ignore commands it has already performed.  However, this implies that the LVM metadata is somehow changed after the action is completed - otherwise it would simply redo these actions upon every activation.  Perhaps I could align my code with that somehow?

In the mean time, I can make the flags so they are written to disk.

 brassow
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111111/90f8d404/attachment.htm>
