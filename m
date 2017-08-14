From: Marcus Müller <marcus@hostalia.de>
Date: Mon, 14 Aug 2017 15:04:59 +0200
Subject: [PATCH 0/1] adding Btrfs resizing capability to lvresize/fsadm.sh
In-Reply-To: <c4a79796-4695-ad57-d42f-2b83daf0f434@suse.com>
References: <20170802174235.19869-1-marcus@hostalia.de>
	<3d78f6d7-dd89-71cb-e754-88a290287404@hostalia.de>
	<bf152578-cca9-b5a1-98a2-4d7a97a21759@suse.com>
	<032e16cc-3e25-04ca-8361-3abb767a0538@redhat.com>
	<c4a79796-4695-ad57-d42f-2b83daf0f434@suse.com>
Message-ID: <8D193B56-60C0-4ED0-9A74-FD13573F6F53@hostalia.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

Thank you for the extensive explanation! I do agree, in this context, unverified functionality might be worse than none :)

Hi Eric,

Please do! And: please don't hesitate to ask for feedback of even better assistance if necessary - you're solving my problems, I'd like to help you with that.

Best regards,
Marcus

On 14 August 2017 2:56:44 PM GMT+02:00, Eric Ren <zren@suse.com> wrote:
>Hi Zdenek and Marcus,
>
>On 08/14/2017 08:50 PM, Zdenek Kabelac wrote:
>> [...snip...]
>>
>> Hi
>>
>> From my memory - when we tried to use such patch in past - we've
>found 
>> too many rough edges on anything  btrfs related.
>>
>> I'm not an expert of btrfs at all - but we noticed lot of troubles in
>
>> terms
>> of  btrfs was not even noticing it has got smaller, disk got missing
>> and many other conditions.
>>
>> So to get such  'btrfs resize' patch accepted - it MUST be equipped
>with
>> lvm2 test suite script - possibly with a new separate test file
>> (so it's not mixed with already complex test/shell/fsadm.sh)
>>
>> It should test fair amount of condition - so we can be at least
>partially
>> sure  'fsadm' will not totally mess users data just because it has
>run
>> command on some unexpected variants of 'btrfs' disk layout.
>>
>> In fact it should check for 'known layout' and only let proceed with
>> command on this path   (including for checking minimal version
>> of kernel and btrfs-tools where btrfs is known to be stable enough
>for 
>> this operation.
>>
>>
>> I do believe that format of /test/shell/*sh is relatively readable.
>> For running the test -
>>
>> do your lvm2 build and then within subdir /test/  run something like:
>>
>> 'make check_local T=fsadm-btrfs.sh VERBOSE=1'
>>
>> to check the tool is doing something useful.
>> If something is unclear - feel free to reach me on freenode #lvm
>channel
>> to get this working properly.
>
>Thanks for your detailed feedback!
>
>I can try to write such a testcase, and ask you
>for review when it's finished ;-)
>
>Cheers,
>Eric
>>
>> Regards
>>
>> Zdenek
>>

-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20170814/342c06a3/attachment.htm>
