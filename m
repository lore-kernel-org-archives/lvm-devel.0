From: Lidong Zhong <lzhong@suse.com>
Date: Mon, 26 Oct 2015 20:29:44 -0600
Subject: [PATCH] lvcreate: support --force option
In-Reply-To: <562E2DC0.1020002@redhat.com>
References: <1444473552-14906-1-git-send-email-lzhong@suse.com>
	<56190FE5.1030900@redhat.com>
	<561B8AEB020000E10001DD25@relay2.provo.novell.com>
	<561B7728.5010804@redhat.com>
	<562E6BD6020000E10001F71D@relay2.provo.novell.com>
	<562E2DC0.1020002@redhat.com>
Message-ID: <562F5218020000E10001F894@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Zdenek,

Thanks for your detailed explanation. I am clear that it's a rule that it prompt every time 
when lvm2 overwrites something.
Once there is a exception in future, I surely will notify the upstream.
Thanks again.

Regards,
Lidong

>>> On 10/26/2015 at 09:42 PM, in message <562E2DC0.1020002@redhat.com>, Zdenek
Kabelac <zkabelac@redhat.com> wrote: 
> Dne 26.10.2015 v 11:07 Lidong Zhong napsal(a): 
> > Hi Zdenek, 
> > 
> >>>> On 10/12/2015 at 05:02 PM, in message <561B7728.5010804@redhat.com>, Zdenek 
> > Kabelac <zkabelac@redhat.com> wrote: 
> >> Dne 12.10.2015 v 04:26 Lidong Zhong napsal(a): 
> >>> Hi Zdenek, 
> >>> 
> >>> Thanks for your reply. 
> >>> 
> >>>>>> On 10/10/2015 at 09:17 PM, in message <56190FE5.1030900@redhat.com>, Zdenek 
> >>> Kabelac <zkabelac@redhat.com> wrote: 
> >>>> Dne 10.10.2015 v 12:39 Lidong Zhong napsal(a): 
> >>>>> The option is supported in the logic of lvcreate but is omitted in 
> >>>>> commands.h. 
> >>>>> 
> >>>> 
> >>>> Nope - it's not intended to be unsupported so far. 
> >>>> 
> >>>> We do support --yes  to overcome prompts. 
> >>>> 
> >>>> Normally --force is meant to be used on paths to proceed with 
> >>>> i.e. lvremove, lvconvert 
> >>>> 
> >>>> Do you have any case in mind where '--force' with lvcreate would have make 
> >> any 
> >>>> 
> >>>> sense ? 
> >>> 
> >>> Not really. I met this problem when I was using lvcreate with the 
> >> --wipesignature option. 
> > 
> > If we set the --wipesignature to y while creating an lv, there will be a  
> prompt for confirming 
> > in current code. Doesn't it make more sense that there shouldn't be the  
> prompt? since we 
> > definitely want to remove the signature by setting this option. 
> > Some options such as "--zero=y" don't give prompt, why it is different? 
> > Please give your opinion. 
> > 
>  
>  
> Hi 
>  
>  
> Here is explanation. 
>  
> 'zero' is unconditional and does not detect any signature - so it has nothing  
>  
> to prompt about - it zeroes first 4K as that's what user asked for. 
>  
> New 'wipesignature' first detects signature and asks if you want to wipe. 
> That's the API (and it's very similar to e.g. mkfs) 
>  
> If lvm2 knows its overwriting something it prompts - that's the rule. 
>  
> If you are going to take a 'risk' for no prompting - use  '--yes' 
>  
> lvm2 is possibly missing couple prompts - so you could possibly open BZ for  
> the case we convert/overwrite something without prompting first. 
>  
> But existing prompts will remain as they are as they are correct. 
>  
> Regards 
>  
> Zdenek 
>  
>  
>  




