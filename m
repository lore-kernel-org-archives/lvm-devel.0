From: Lidong Zhong <lzhong@suse.com>
Date: Tue, 10 Mar 2015 02:13:04 -0600
Subject: [PATCH] fsadm: add support for btrfs
In-Reply-To: <54FD5A6F.90806@redhat.com>
References: <1425883705-8022-1-git-send-email-lzhong@suse.com>
	<54FD5A6F.90806@redhat.com>
Message-ID: <54FF1810020000E10001D266@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Ondrej,
Thank you for your reply.
>>> On 3/9/2015 at 04:31 PM, in message <54FD5A6F.90806@redhat.com>, Ondrej Kozina
<okozina@redhat.com> wrote: 
> On 03/09/2015 07:48 AM, Lidong Zhong wrote: 
> > Run `btrfs check` to check filesystem 
> > Run `btrfs filesystem show` to get the filesystem size and 
> > `btrfs filesystem resize` to resize. 
> > 
>  
> Hi, 
>  
> thank you for the patch but I'm afraid it is not correct. For example it  
> doesn't seem to deal with the possibility of btrfs volume spanning  
> across multiple block devices. You have to resize (meant with btrfs  
> tools) specific subvolume to not to break the filesystem on LV about to  
> get resized with lvresize. 

Yeah, I didn't think of that. But the solution is already in your patch.  I guess this
is not a problem. right?

>  
> I proposed similar patch before  
> (http://www.redhat.com/archives/lvm-devel/2012-November/msg00052.html)  
> but in the end came to conclusion it was not worth the pain considering  
> the btrfs-check couldn't detect even elemental fs breakage. Is the state  
> of btrfs-check tool better than what I described earlier in my patch header? 

How about mount the device on a tmp place(as temp_mount()) first and then run
  btrfs scrub start -B device
and check if the error is zero in the output?
(or the return value of the command is not zero)

Regards,
Lidong
>  
> Kind regards 
> Ondrej 
>  
> PS: The original patch is from 2012 so perhaps some of the magic I used  
> to extract proper btrfs device id is useless as of now. At least I hope  
> so... 
>  
> -- 
> lvm-devel mailing list 
> lvm-devel at redhat.com 
> https://www.redhat.com/mailman/listinfo/lvm-devel 
>  
>  




