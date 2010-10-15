From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 15 Oct 2010 14:55:37 +0200
Subject: [PATCH] automatic snapshot extension with dmeventd (BZ 427298)
In-Reply-To: <87aamffz2u.fsf@twilight.int.mornfall.net.>
References: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>	<87r5g4lejw.fsf@twilight.int.mornfall.net.>	<4CB6D2BC.9060404@redhat.com>
	<87aamffz2u.fsf@twilight.int.mornfall.net.>
Message-ID: <4CB84F49.9020602@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15.10.2010 13:57, Petr Rockai napsal(a):
> Zdenek Kabelac <zkabelac@redhat.com> writes:
> 

>>> +	if (policy_threshold >= 100)
>>> +		return 1; /* nothing to do */
>>
>> For some really large sizes - even 1% could be a huge amount of disk space -
>> so maybe some users would like to see floating number support here?
> 
> I'd open a separate bug for that, if you really think so. I tend to
> disagree. (Btw. there's no single float config option in LVM today --
> even though there is theoretical support for that, it's probably not
> tested at all.)
> 

Yes - we do not currently use floats in lvm.conf. Another version could be, to
allow setting also in some absolute sizes - i.e.

snapshot_autoextend_free = 100MB
snapshot_autoextend_size = 200MB


Ok - I've tested the patch - and it seems to be working.

So ACK from my side.

What I see as a problem for the future is how to resolve settings per each
snapshot as current  'global' version - one setting for all snapshots is IMHO
quite limiting.


Zdenek


