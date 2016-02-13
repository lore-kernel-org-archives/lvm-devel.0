From: Bernd Kuhls <bernd.kuhls@t-online.de>
Date: Sat, 13 Feb 2016 19:48:01 +0100
Subject: MUSL fun
References: <CA+BsyQ4tDvVFXyo2Po9jiFKVobaJhMy7PoxWjczT8KFK9BrXWQ@mail.gmail.com>
Message-ID: <1ca4pcxqnk.ln2@ID-313208.user.individual.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Am Tue, 15 Sep 2015 17:43:58 +0100 schrieb Brendan Heading:

> In theory a straightforward fix would be to do something like:
> 
> if (!freopen(NULL, "r", stdin))
>      goto out;
> 
> .. but I suspect there is a good reason why this isn't done. Can anyone
> shed any light on this ? If not I will submit a patch.

Hi Brendan,

the buildroot project also supports musl, the build of lvm2 fails due to 
the problem you described. Did you find a working solution for the 
problem? A patch I submitted to the buildroot project, based on patches I 
found at the Alpinelinux project, raised some questions I am unable to 
answer: http://patchwork.ozlabs.org/patch/573519/

Regards, Bernd


