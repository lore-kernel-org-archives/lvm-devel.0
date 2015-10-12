From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 12 Oct 2015 11:02:32 +0200
Subject: [PATCH] lvcreate: support --force option
In-Reply-To: <561B8AEB020000E10001DD25@relay2.provo.novell.com>
References: <1444473552-14906-1-git-send-email-lzhong@suse.com>
	<56190FE5.1030900@redhat.com>
	<561B8AEB020000E10001DD25@relay2.provo.novell.com>
Message-ID: <561B7728.5010804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.10.2015 v 04:26 Lidong Zhong napsal(a):
> Hi Zdenek,
>
> Thanks for your reply.
>
>>>> On 10/10/2015 at 09:17 PM, in message <56190FE5.1030900@redhat.com>, Zdenek
> Kabelac <zkabelac@redhat.com> wrote:
>> Dne 10.10.2015 v 12:39 Lidong Zhong napsal(a):
>>> The option is supported in the logic of lvcreate but is omitted in
>>> commands.h.
>>>
>>
>> Nope - it's not intended to be unsupported so far.
>>
>> We do support --yes  to overcome prompts.
>>
>> Normally --force is meant to be used on paths to proceed with
>> i.e. lvremove, lvconvert
>>
>> Do you have any case in mind where '--force' with lvcreate would have make any
>>
>> sense ?
>
> Not really. I met this problem when I was using lvcreate with the --wipesignature option.
> --yes works for me. But I also found that --force should also work when I read the source.
> However, it reports -f/--force is an invalid option for lvcreate.

Yep - and so far it should stay that way -  --force has special meaning for 
being quite unsafe operation.

>
>> IMHO creating something with --force looks to me like crazy idea to start with
>>
>> - but maybe there is some use-case I'm missing ?
>>
>
> Currently there is no introduction to --yes in the manpage of lvcreate. How about adding it to
> the manpage?

Every lvm man page references 'man lvm' as the source of description for all 
'commonly' accepted options (like --yes).

One day we may switch to 'generated' man pages - where very man page would 
have all options described - but I guess this 'day' is still pretty far away ;)

Regards

Zdenek



