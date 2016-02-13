From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 13 Feb 2016 22:02:55 +0100
Subject: MUSL fun
In-Reply-To: <CA+BsyQ6ihax71VER=dgCHF-eV0mfjYqZo6LixK21BVrMCGb-Bg@mail.gmail.com>
References: <CA+BsyQ4tDvVFXyo2Po9jiFKVobaJhMy7PoxWjczT8KFK9BrXWQ@mail.gmail.com>
	<1ca4pcxqnk.ln2@ID-313208.user.individual.net>
	<CA+BsyQ6ihax71VER=dgCHF-eV0mfjYqZo6LixK21BVrMCGb-Bg@mail.gmail.com>
Message-ID: <56BF99FF.1030900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.2.2016 v 20:22 Brendan Heading napsal(a):
> Bernd,
>
> [cc buildroot]
>
> Like you I'd been investigating this issue from the buildroot end.
> Since October I've had no spare time to look at buildroot fixes.
>
> I was hoping for an explanation about why LVM implemented the above
> behaviour, but I never got one, and I didn't fancy working on a patch
> that would never get accepted when other projects were more open ..
>
> I think the best approach is probably just to add the freopen() patch
> as Romain suggested and keep the patch available in buildroot in the
> hope that we can build support for LVM to accept it.
>
> Brendan
>
>
> On 13 February 2016 at 18:48, Bernd Kuhls <bernd.kuhls-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org> wrote:
>> Am Tue, 15 Sep 2015 17:43:58 +0100 schrieb Brendan Heading:
>>
>>> In theory a straightforward fix would be to do something like:
>>>
>>> if (!freopen(NULL, "r", stdin))
>>>       goto out;
>>>
>>> .. but I suspect there is a good reason why this isn't done. Can anyone
>>> shed any light on this ? If not I will submit a patch.
>>
>> Hi Brendan,
>>
>> the buildroot project also supports musl, the build of lvm2 fails due to
>> the problem you described. Did you find a working solution for the
>> problem? A patch I submitted to the buildroot project, based on patches I
>> found at the Alpinelinux project, raised some questions I am unable to
>> answer: http://patchwork.ozlabs.org/patch/573519/
>>
>> Regards, Bernd


Let's start from the beginning -

-- 
commands/toolcontext.c: In function 'create_toolcontext':
commands/toolcontext.c:1796:10: error: assignment of read-only variable 'stdin'
     stdin = new_stream;
-- 

So now - from where comes the idea  of  'stdin' being read-only variable ?
Looking at some POSIX spec e.g.:
http://pubs.opengroup.org/onlinepubs/009695399/functions/stdin.html

there is no sign of having this read-only var.

So what kind of OS this actually is ?


There is a reason from lvm2 implementation here - freopen() is not giving 
application full control over internal buffer allocation and we need to be 
sure we lock-in memory for critical section - and some glibc versions are 
allocating buffers here via 'mmap' call.

That said - there could be accepted a patch checking in configure  for
'read-only' stdin  - and using then #ifdef compilation that would
replace use of  internal lvm2 reopen code with libc function.

But the currently posted patch may possibly cause some other regressions.

Regards

Zdenek


