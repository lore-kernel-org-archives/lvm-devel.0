From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 24 Feb 2010 10:39:17 +0100
Subject: lvm and locales memory issue
In-Reply-To: <20100223162842.GC2817@tyan-ft48-01.lab.bos.redhat.com>
References: <4B7D372D.4060608@redhat.com>
	<4B7D4014.3010205@redhat.com>	<4B7EB81D.6090405@redhat.com>	<20100219163008.GR27427@agk-dp.fab.redhat.com>	<4B8262A2.4050408@redhat.com>
	<4B8283B6.7000808@redhat.com>	<20100222181150.GA32020@agk-dp.fab.redhat.com>	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>	<4B839743.8020909@redhat.com>
	<4B83F193.9020209@redhat.com>
	<20100223162842.GC2817@tyan-ft48-01.lab.bos.redhat.com>
Message-ID: <4B84F3C5.9060100@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 23.2.2010 17:28, Jakub Jelinek wrote:
>> Another note could be - Ubuntu does not even use locale-archive file and uses
>> locales on per file basis - so now I'm getting curious, where are the tests,
> 
> Not everything Ubuntu does is necessarily a good idea.
> 
>> that proves that Fedora gets some measurable performance advantage?
> 
> Try something trivial, like:
> #include <locale.h>
> 
> int
> main (void)
> {
>   int i;
>   for (i = 0; i < 1000000; i++)
>     switch (i % 5)
>       {
>       case 0: setlocale (LC_ALL, "C"); break;
>       case 1: setlocale (LC_ALL, "en_US.UTF-8"); break;
>       case 2: setlocale (LC_ALL, "cs_CZ.UTF-8"); break;
>       case 3: setlocale (LC_ALL, "fr_FR.UTF-8"); break;
>       case 4: setlocale (LC_ALL, "de_DE.UTF-8"); break;
>       }
>   return 0;
> }
> 
> With locale-archive 1.362s, without, using locale files, 10.355s.  And


>From looking into the code and keeping in mind we need to handle these
millions of switches per second as a killer feature - there seems to be nice
way -  instead of doing one large mmap call - how about doing several
smaller sized mmap just for regions needed by given locale.

Once mmap-ed - it will stay in program's memory till its exit just like now...

So - instead of one large 100MB mmap - we would end for this 'benchmark'
with maybe 8-10 mmap calls per setlocale - so let's say 50 mmap calls for
small memory regions. (or less - depends on how the locale-archive is
organized - maybe everything except LC_CTYPE & LC_COLLATE could be in on
mmaped area)

As a bonus - for the most common use-case - it might eat less pgt entries
(I assume its ~190kb for x86_64 and 100MB file)
On the opposite site - user of all locales at once would waste memory by
having some pages mmmaped multiple times....

Zdenek


