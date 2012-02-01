From: Busby.Cheung <chaimvy@163.com>
Date: Wed, 1 Feb 2012 09:42:29 +0800 (CST)
Subject: [linux-lvm] New LVM2 release 2.02.89: Thinly-provisioned logical volumes
In-Reply-To: <20120131132318.GH16447@agk-dp.fab.redhat.com>
References: <20120131132318.GH16447@agk-dp.fab.redhat.com>
	<20120127025701.GB16767@agk-dp.fab.redhat.com>
	<1eaeb3d5.c6e.135332dea21.Coremail.chaimvy@163.com>
Message-ID: <582e15fb.4e8.1353693c7ce.Coremail.chaimvy@163.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,
             It works well as  what you said in the email. Thanks!

Best regards,
Busby

 
 > -----????-----
> ???: "Alasdair G Kergon" <agk@redhat.com>
> ????: 2012?1?31? ???
> ???: "LVM general discussion and development" <linux-lvm@redhat.com>
> ??: dm-devel at redhat.com, lvm-devel at redhat.com
> ??: Re: [linux-lvm] New LVM2 release 2.02.89: Thinly-provisioned	logical volumes
> 
> On Tue, Jan 31, 2012 at 05:52:21PM +0800, Busby.Cheung wrote:
> >        I tryed to use this LVM2 to create thin pool and thin lv, but it said PE was required. The VG I used is free, can anyone help me? Should any more args be needed? Is there any more detailed HowTo file than man file?
>   
> 
> For now, you need either 2 PVs in the VG, or use --alloc anywhere with 1 PV, or
> split the allocation manually like:
> 
> > [root at host2 ~]# lvcreate  -L100M -T vg_pool/pool -V 1T --name thin_lv /dev/sdl:0 /dev/sdl:1-
> 
> I have a patch that fixes this problem, but I'm still testing it.
> 
> Alasdair
> 
> 
> _______________________________________________
> linux-lvm mailing list
> linux-lvm at redhat.com
> https://www.redhat.com/mailman/listinfo/linux-lvm
> read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO/
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120201/62c16b01/attachment.htm>
