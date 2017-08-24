From: Marcus Müller <mueller@kit.edu>
Date: Thu, 24 Aug 2017 14:49:45 +0200
Subject: 答复： Re: [PATCH 1/1] added resizing for btrfs
In-Reply-To: <599F50CE020000D40009B179@prv-mh.provo.novell.com>
References: <20170802174235.19869-1-marcus@hostalia.de>
	<20170802174235.19869-2-marcus@hostalia.de>
	<2c307eee-72f8-7283-6bc0-f7072e652ca2@suse.com>
	<f65efe40-1f9b-dd94-5ab3-70802ebce6f1@kit.edu>
	<599F50CE020000D40009B179@prv-mh.provo.novell.com>
Message-ID: <9939b97d-e6ba-ceeb-0477-041a634a216d@kit.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/24/2017 02:18 PM, Zhen Ren wrote:
> Hi,
>
> Sorry for the delay.
>
>>>> Marcus M?ller <mueller@kit.edu> 2017-8-24 pm 15:25 >>>
> Hi Eric,
>
>>> ha! Nearly escaped my memory.
>>> Re: your (justified) objections:
>> 1. lack "check" action in your script
>> In patch [1], it uses "btrfs scrub", which I think you can replace it
>> with "btrfs check".
>>> 1. You're right; `btrfs scrub` just checks the file/metadata checksums
>>> on a live system (and can thus correct /file breakage/), whereas `btrfs
>>> check` checks for structural damage.
>>> I'm not sure `btrfs scrub` is the right thing to do ? certainly, it will
>>> detect corrupted blocks; but as far as I can see, these aren't a problem
>>> at all during resizing; they would be moved untouched.
>>> I'm, on the other hand, also not sure we should implement anything here
>>> ? other filesystem checks are simply skipped if the filesystem is
>>> already mounted (and mounting is a requirement for resizing). `btrfs
>>> check` would take a long time.
> Yeah, I overlooked this potential problem. IMHO, fsadm should have a option to
> decide if "check" is required after resize.
>
>>> So, either btrfs check or a nop; either is fine with me, what would you
>>> prefer?
> Hmm, the SUSE-specific patch was reviewed by btrfs-tools maintainer David Sterba, and tested
> by btrfs guys. I'd suggest to keep the way to check with "btrfs scrub" as in that patch.
>
> Please send v2 after your changes, and I'll get the v2 patch, test it and then send the respective
> test script for Zdenek review.
>
> Thanks!
> Eric
>
>

Hi Zhen,

I'm certainly not one to withhold a revised patch, but: If Lidong Zhong 
(hi!) got his patch reviewed already from btrfs folks ? I might 
personally prefer that

For example, the mount point detection based on the external `findmnt` 
program (didn't know that existed) looks more robust, and precautions 
that I didn't take (like setting LC_ALL for calling `btrfs`) indicate 
that the best-case modification of my patch would actually be his patch. 
I haven't thought of it this way so far.

Do you still want me to modify my patch?

Best regards,
Marcus


