From: Lidong Zhong <lzhong@suse.com>
Date: Tue, 27 Oct 2015 21:49:12 -0600
Subject: [PATCH] dmeventd: compare dso name with "-"
In-Reply-To: <562F56FB.2070008@redhat.com>
References: <1445931417-9667-1-git-send-email-lzhong@suse.com>
	<562F56FB.2070008@redhat.com>
Message-ID: <5630B638020000E10001FB0A@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>>> On 10/27/2015 at 06:50 PM, in message <562F56FB.2070008@redhat.com>, Zdenek
Kabelac <zkabelac@redhat.com> wrote: 
> Dne 27.10.2015 v 08:36 Lidong Zhong napsal(a): 
> > If the dso name is not set in client, then it will be replaced by "-". 
> > So the server should compare the dso name with "-" to decide whether 
> > it is set. 
>  
> Hi 
>  
> Tried to fix this differently: 
>  
> https://www.redhat.com/archives/lvm-devel/2015-October/msg00163.html 
>  
>  
> Please let me know if this has fixed problem for you. 
> (dmevent_tool is from already 'dead' project  dmraid - so untested) 
>  

Hi Zdenek,

The fix works well for dmevent_tool. 

Regards,
Lidong

> Regards 
>  
> Zdenek 
>  
> -- 
> lvm-devel mailing list 
> lvm-devel at redhat.com 
> https://www.redhat.com/mailman/listinfo/lvm-devel 
>  
>  




