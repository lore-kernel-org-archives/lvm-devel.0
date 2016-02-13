From: Brendan Heading <brendanheading@gmail.com>
Date: Sat, 13 Feb 2016 19:22:38 +0000
Subject: MUSL fun
In-Reply-To: <1ca4pcxqnk.ln2@ID-313208.user.individual.net>
References: <CA+BsyQ4tDvVFXyo2Po9jiFKVobaJhMy7PoxWjczT8KFK9BrXWQ@mail.gmail.com>
	<1ca4pcxqnk.ln2@ID-313208.user.individual.net>
Message-ID: <CA+BsyQ6ihax71VER=dgCHF-eV0mfjYqZo6LixK21BVrMCGb-Bg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Bernd,

[cc buildroot]

Like you I'd been investigating this issue from the buildroot end.
Since October I've had no spare time to look at buildroot fixes.

I was hoping for an explanation about why LVM implemented the above
behaviour, but I never got one, and I didn't fancy working on a patch
that would never get accepted when other projects were more open ..

I think the best approach is probably just to add the freopen() patch
as Romain suggested and keep the patch available in buildroot in the
hope that we can build support for LVM to accept it.

Brendan


On 13 February 2016 at 18:48, Bernd Kuhls <bernd.kuhls@t-online.de> wrote:
> Am Tue, 15 Sep 2015 17:43:58 +0100 schrieb Brendan Heading:
>
>> In theory a straightforward fix would be to do something like:
>>
>> if (!freopen(NULL, "r", stdin))
>>      goto out;
>>
>> .. but I suspect there is a good reason why this isn't done. Can anyone
>> shed any light on this ? If not I will submit a patch.
>
> Hi Brendan,
>
> the buildroot project also supports musl, the build of lvm2 fails due to
> the problem you described. Did you find a working solution for the
> problem? A patch I submitted to the buildroot project, based on patches I
> found at the Alpinelinux project, raised some questions I am unable to
> answer: http://patchwork.ozlabs.org/patch/573519/
>
> Regards, Bernd
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


