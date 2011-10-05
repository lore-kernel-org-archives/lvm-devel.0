From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 05 Oct 2011 11:06:10 +0200
Subject: [PATCH v3 01/18] fsadm: Add new commands create, list, add and remove
In-Reply-To: <alpine.LFD.2.00.1110050932530.4423@dhcp-27-109.brq.redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-2-git-send-email-lczerner@redhat.com>
	<4E8AD4CF.3080609@redhat.com>
	<alpine.LFD.2.00.1110041336440.4206@dhcp-27-109.brq.redhat.com>
	<4E8B3DE5.2080803@redhat.com>
	<alpine.LFD.2.00.1110050932530.4423@dhcp-27-109.brq.redhat.com>
Message-ID: <4E8C1E02.9090308@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.10.2011 10:02, Lukas Czerner napsal(a):
> On Tue, 4 Oct 2011, Zdenek Kabelac wrote:
>
>> Dne 4.10.2011 14:13, Lukas Czerner napsal(a):
>>> On Tue, 4 Oct 2011, Zdenek Kabelac wrote:
>>>


>>>> Well user is always the master - if he is brave to go without it, let him
>>>> do
>>>> what he wants (i.e. destroy his fs).
>>>
>>> You're missing the point, resize2fs requires that the file system is
>>> checked with e2fsck -f prior the resize, if on of the conditions happen
>>>
>>> 1. file system was not cleanly umounted
>>> 2. file system contain errors, or is invalid
>>> 3. it was not checked since the last time it was mounted
>>>
>>> It is just to make sure that the file system is consistent and we will
>>> not make everything worse by messing with metadata further.
>>>
>>
>> If the user wants to risk  resize2fs without fsck - it's his decision (and
>> current -f with fsadm allows it) - and since we are not like gnome3 - we allow
>> users to kill their systems in number of ways already, so no reason to
>> eliminate this one.
>
> Well, this is just wrong in so many ways. Running fsck.ext4 -f to force
> the full check is not the same as skipping the fsck before resize in the
> tool which is suppose to do-it-all. We have to pick the safe way here.
>

Tool is not meant to be used only in a 'safe' way - tool is supposed to fully 
usable even various force scenarios - i.e. when fsck support options '-y' we 
should be able to use - even if some extX developers think it's very 
dangerous option and should never ever be used - it's there and it has its 
use. (I've used it already many times, and nothing unexpectedly bad happened).

What we could do here better is to draw some state diagram and eventually add 
few more options - but we will not strip down the usefulness of fsadm only for 
clean filesystem and leave the user  to run  fsck -y on its - as we can do 
that for him.


>>
>> i.e. mkfs, mount, umount, resize LV, resize2fs -f   works without fsck and
>> makes errorless result - so we support.
>
> Also it makes me think that you do not really see what is in the code.
> There is nothing about about 'force', fsck is done anyway (in the old
> code - your code) in the case that
>
> [ "$NEWBLOCKCOUNT" -lt "$BLOCKCOUNT" -o "$EXTOFF" -eq 1 ]
>
> and
>
> if test -n "$MOUNTED"
>
> so please, read before you write.

man lvresize  --nofsck


> Also your arguments are out of the line. There are different levels of
> granularity of force, and if user force things he does not expect things
> will be done in wrong way. That said, when I use force I do not want to
> be asked about stupid questions, but I certaily do not want fsck before
> resize2fs to be skipped.

We already allow that - since there are situation you may need to use it.

> You just have to understand that we are using multiple tools in fsadm
> and just passing force to all of them would be incredibly stupid, even
> if you properly document it.

Certainly personal opinion.

As already said - provide state diagram and suggest more options
(in lvm we use  -ff for some situations -  so maybe more levels of force)

But we need to support what we already can do with fsadm tool.

If the user puts --force anywhere on the command line - he surely needs to 
expect, that some things may cause damage.

> his 'force' and what consequences will that have. We just HAVE to pick
> the most logical and most safe way of doing things. But your way of

There is no 'safe' way with --force - that's the purpose of force.
However there could be multiple force levels.

Zdenek


