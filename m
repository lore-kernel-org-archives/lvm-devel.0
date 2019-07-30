From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Tue, 30 Jul 2019 14:53:18 +0530
Subject: lvmcache in writeback mode gets stuck flushing dirtyblocks
In-Reply-To: <54fa6178-88c8-0236-8595-2c19a6e4b73f@redhat.com>
References: <5d3fce60.1c69fb81.f521b.46a8@mx.google.com>
	<54fa6178-88c8-0236-8595-2c19a6e4b73f@redhat.com>
Message-ID: <5d400c85.1c69fb81.b383c.5221@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,
Thank you for the acknowledging the issue.

I may not be at a liberty to choose the environment always, as most of the major distributions come bundled with 2.02.133
I have two followup questions.
1/ Is there a way to tell that a particular version has very critical bug (like the one I reported)? Nothing short of hitting it seem the way to confirm currently.
2/ which is the nearest stable release that addresses this particular issue?
3/ Does latest lvm stable work well in old distributions, Linux kernels too? Whats the compatibility matrix here? 

Regards
LN

From: Zdenek Kabelac
Sent: Tuesday, July 30, 2019 1:51 PM
To: LVM2 development; Lakshmi Narasimhan Sundararajan
Subject: Re: [lvm-devel] lvmcache in writeback mode gets stuck flushing dirtyblocks

Dne 30. 07. 19 v 6:58 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> 
> A very good day to all.
> 
> 
> I am using lvmcache in writeback mode. When there are dirty blocks still in 
> the lv, and if needs to be destroyed or flushed, then
> 
> It seems to me that there are some conditions under which the dirty data flush 
> gets stuck forever.
> 
> As an example:
> 
> root at pdc4-sm35:~# lvremove -f pwx0/pool
> 
>  ? 367 blocks must still be flushed.
> 
>  ? 367 blocks must still be flushed.
> 
>  ? 367 blocks must still be flushed.

> I am running these version:
> 
> root at pdc4-sm35:~# lvm version
> 
>  ? LVM version:???? 2.02.133(2) (2015-10-30)
> 
> I filed one here myself, https://github.com/lvmteam/lvm2/issues/22, trying? to 
> understand from you experts where we are on this?
> 
> I would sincerely appreciate your help in understanding the state of this 
> issue in more detail.

Hi

Yep you are using very old version of lvm2 - there is already year 2019 - and 
in the initial releases of lvm2 with writeback cache support (as you happen to 
still use these days) there was a problem that uncaching was not switching to 
writethrough mode (and this was not the only one)

Please consider to use way newer lvm2 & kernel.

Regards

Zdenek

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190730/5a5c1a2e/attachment.htm>
