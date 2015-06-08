From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 08 Jun 2015 10:38:29 +0200
Subject: [RFC 0/6] Waiting for the missing device in mirror
In-Reply-To: <1433749712-11837-1-git-send-email-lzhong@suse.com>
References: <1433749712-11837-1-git-send-email-lzhong@suse.com>
Message-ID: <55755485.2080802@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 8.6.2015 v 09:48 Lidong Zhong napsal(a):
> Hi List,
>
> The implementation here is trying to add another policy for the
> missing leg/log device in mirror. We want to wait the device for some
> time in case of a temporary device failure, especially a network disconnection
> for clvmd, to avoid a full disk recovery.
>
> This version is kind of a draft. There are many immature places to improve. So comments
> and suggestions are welcomed.
>
> The responding kernel part is here:
> https://git.kernel.org/cgit/linux/kernel/git/device-mapper/linux-dm.git/
> commit/?h=for-next&id=ed63287dd670f8e9d2412a913de7fdc50a689831

Hi

I think you should please start first with the very precise description what 
you are trying to achieve/fix - then we should discuss how to reach desired goal.

With very light overview of patches there are number of problem which can't 
fit lvm2 design.

#1 - Never store any device major:minor in lvm2 metadata - everything is 
strictly PV UUID oriented (there are number of daemons these days)

#2 - Activation layer & Command layer are 2 separate entities - so your 
command may run on different node then the actual activation happens (unless 
you do a local activation) -  the layer separator is ATM 'lock' - the code 
before lock and  after lock do not share any data - and the 'activation' layer 
knows only what is in written metadata on disk (just for optimization purposes 
there is some internal mechanism of caching and reusing of some existing data).

#3 - There is no 'hidden' data exchange channel via /tmp for activation - 
everything goes strictly via written and committed metadata, and for every 
such metadata state there needs to be some clear recovery path (e.g. what 
happens after 'power-off' with each committed lvm2 metadata state)

I do not yet quite understand what are you trying to achieve - but I've not 
noticed any patch for 'dmeventd' which is the actual tool that fixes broken 
mirrors - so could that tool by anyhow used for detection of some temporary 
network failures ?

Regards

Zdenek


