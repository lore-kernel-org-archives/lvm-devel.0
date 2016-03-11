From: Liuhua Wang <lwang@suse.com>
Date: Fri, 11 Mar 2016 15:35:59 +0800
Subject: pvchange returns 5 when the other vg is exported
In-Reply-To: <20160310193937.GB22047@redhat.com>
References: <20160310102326.GA14371@wlh-host.lab.bej.apac.novell.com>
	<20160310193937.GB22047@redhat.com>
Message-ID: <20160311073559.GA6191@wlh-host.lab.bej.apac.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

On Thu, Mar 10, 2016 at 01:39:37PM -0600, David Teigland wrote:
> > 
> >    Because vg2 is exported and vg2 locates on the head of list, firstly vg_read(vg2) 
> >    will cause set read error and cause ignore_vg() to return 1 (read_error != SUCCESS)
> >    
> >    Then ret_max remains ECMD_FAILED(5) and is returned. I don't think returning error
> >    is expected since vg2 has no relationship with /dev/vdb1.
> 
> Thanks, I've fixed this here:
> https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=0f10823ec910c0a6015b20580f5aa26f209cea04

I tested the patch works. Thanks a lot!
---
Best,
Liuhua


