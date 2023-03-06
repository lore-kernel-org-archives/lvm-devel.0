From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 6 Mar 2023 18:01:41 +0100
Subject: lvmetad status
In-Reply-To: <CAFe+wq1_AqQRREpvW9AkztbC54+mbWWb7nOQD=pCzERrg25JZQ@mail.gmail.com>
References: <CAFe+wq235CR3DavwD+z200MAe4-CnWQveF2CX2S5vm0qSmTfLA@mail.gmail.com>
 <655bd398-9bc0-7b1c-0891-598ca4c8d36d@redhat.com>
 <CAFe+wq1_AqQRREpvW9AkztbC54+mbWWb7nOQD=pCzERrg25JZQ@mail.gmail.com>
Message-ID: <eac714ba-d5a8-4f15-44b0-7b7afbfdae49@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 06. 03. 23 v 16:02 Lakshmi Narasimhan Sundararajan napsal(a):
> Thanks Zdenek, How about in memory caching of device properties? That was 
> also supposedly a function of lvmetad isnt?it?
> Do we have a suitable replacement for the same?
>
> Also, why is lvmetad deprecation not called out more noticeable. I still see 
> man pages and many distro continue to use lvmetad.
>

Hi

Technical difficulties? associated with keep lvmetad in up-to-date state have 
been? high - and the replacement, which uses the the structures/files in 
/run/lvm directory in form of hints is more easier to maintain and we are able 
to achieve similar functionality as with running daemon.? It's worth to be 
noted that lvm2 is now using significantly faster scanning mechanism - so the 
usage of lvmetad in same cases has been actually slow-downing the system....

See the man page?? 'man lvmautoactivation'? for more detailed description 
(although the page needs some updating as we have improved recently some pieces).

Regards

Zdenek

