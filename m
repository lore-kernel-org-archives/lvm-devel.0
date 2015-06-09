From: Lidong Zhong <lzhong@suse.com>
Date: Mon, 08 Jun 2015 21:19:55 -0600
Subject: [RFC 0/6] Waiting for the missing device in mirror
In-Reply-To: <55755485.2080802@redhat.com>
References: <1433749712-11837-1-git-send-email-lzhong@suse.com>
	<55755485.2080802@redhat.com>
Message-ID: <5576CBDB020000E10000FE8B@relay2.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>> On 6/8/2015 at 04:38 PM, in message <55755485.2080802@redhat.com>, Zdenek
Kabelac <zkabelac@redhat.com> wrote: 
> Dne 8.6.2015 v 09:48 Lidong Zhong napsal(a): 
> > Hi List, 
> > 
> > The implementation here is trying to add another policy for the 
> > missing leg/log device in mirror. We want to wait the device for some 
> > time in case of a temporary device failure, especially a network  
> disconnection 
> > for clvmd, to avoid a full disk recovery. 
> > 
> > This version is kind of a draft. There are many immature places to improve.  
> So comments 
> > and suggestions are welcomed. 
> > 
> > The responding kernel part is here: 
> > https://git.kernel.org/cgit/linux/kernel/git/device-mapper/linux-dm.git/ 
> > commit/?h=for-next&id=ed63287dd670f8e9d2412a913de7fdc50a689831 
>  
> Hi 
>  
Hi Zdenek,

Thanks for your reply.
> I think you should please start first with the very precise description what  
>  
> you are trying to achieve/fix - then we should discuss how to reach desired  
> goal. 
>  

Sorry, my fault. Here is the situation:
If one leg of the mirror fails, according to current implementation, the failed leg 
will either be removed or be replaced. However, if it is a temporary failure( such as
network failure in clvmd), we have to do a full sync for the disk if we re-add it as mirror ,
which will cost a long time. So we plan to add another policy for the missing device, that is 
waiting the device for a configurable time. Then we could just do a incremental sync
for the device while it's disappeared.

What I do in the patch series is:
Add a new feature for the mirror target, which enables bios still could be written to the left 
mirror devices and also keep the bitmap. The implementation has been done for the kernel.
We add a KEEP_LOG feature, which depends on current HANDLE_ERRORS feature. For the 
userspace, we should add the parameter --trackchanges if we create a dm-mirror device to 
enable this feature.
When dmeventd gets a device failure event, it will call lvconvert according to the policy set in
lvm.conf. So most of our work is for lvconvert command.
We add another policy, that is mirror_keep_log/mirror_keep_log_timeout in activation section.
If this policy is set, then we will make it a daemon to wait for the missing device within 
mirror_keep_log_timeout. If it doesn't comes back, it will act the same as before based on
the mirror_device_fault_policy set. Otherwise, it will start the incremental sync and return.
Some immature points are:
1\ It will create a temporary file named by UUID of the device under /tmp file, in case of there
are two or more failed devices and the daemons wait for the same one.
2\ The major:minor of the missing device probably changes when it comes back. So I put the original
device number into metadata.(As already pointed out, it does not fit the rule.)

and some others.

> With very light overview of patches there are number of problem which can't  
> fit lvm2 design. 
>  
> #1 - Never store any device major:minor in lvm2 metadata - everything is  
> strictly PV UUID oriented (there are number of daemons these days) 
>  

I thought about storing this info into lvmetad. But if lvmetad service is not running,
then what should we do.

> #2 - Activation layer & Command layer are 2 separate entities - so your  
> command may run on different node then the actual activation happens (unless  
>  
> you do a local activation) -  the layer separator is ATM 'lock' - the code  
> before lock and  after lock do not share any data - and the 'activation'  
> layer  
> knows only what is in written metadata on disk (just for optimization  
> purposes  
> there is some internal mechanism of caching and reusing of some existing  
> data). 
>  

I don't quite understand this part. I guess it's related to the replacing table info and 
starting sync in my code. I will look deep into this part. Thanks.

> #3 - There is no 'hidden' data exchange channel via /tmp for activation -  
> everything goes strictly via written and committed metadata, and for every  
> such metadata state there needs to be some clear recovery path (e.g. what  
> happens after 'power-off' with each committed lvm2 metadata state) 
>  

You mean I should put the waiting device info into metadata?


Regards,
Lidong

> I do not yet quite understand what are you trying to achieve - but I've not  
> noticed any patch for 'dmeventd' which is the actual tool that fixes broken  
> mirrors - so could that tool by anyhow used for detection of some temporary  
> network failures ? 
>  
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



