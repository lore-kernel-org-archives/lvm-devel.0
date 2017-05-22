From: Eric Ren <zren@suse.com>
Date: Mon, 22 May 2017 12:09:41 +0800
Subject: Wrong locking type on local VG when clvm is used?
In-Reply-To: <20170519030520.GB15801@agk-dp.fab.redhat.com>
References: <d24e1f13-4a0c-71f7-a4cb-bc3c7fda3bb7@suse.com>
	<20170519030520.GB15801@agk-dp.fab.redhat.com>
Message-ID: <291cb549-5603-3148-74f9-767581c3842a@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

On 05/19/2017 11:05 AM, Alasdair G Kergon wrote:
> On Fri, May 19, 2017 at 10:46:09AM +0800, Eric Ren wrote:
>> Looking a bit at the code, LVM decides the locking_type on command basis, i.e. wrapping
>> the command around with init_locking() and fin_locking(). So, I'm thinking if we can change
>> locking_type selection to VG basis. For example, "vgchange -ay local_vg cluster_vg", we can
>> decide the locking_type for each VG. Well, it's overkill if all the VGs are either local, or
>> cluster... Is this reasonable, or something worth to do?
> Probably not - it's not really worth that level of complexity - we
> considered it several times before but always ruled it out.  (We did
> tackle part of the difficulty when introducing lvmlockd though.)  The
> workaround is easy - you already found one - and I thought the case you
Yes, thanks for sharing your thoughts!
> described used to work anyway (if the daemon couldn't find the object
Sorry, which daemon do you mean? clvmd or lvmetad...
It looks to me that lvmetad can do what you point out here. However,
lvmetad is not used when clvm is in use, right? And, clvmd, seemingly,
doesn't fail back to scan automatically. That's why 'clvmd -R' exists?
> referenced it used to trigger a scan so it would find it) so it might
> just be needing some bug fix or varied configuration setting.
I tested on various versions including:
CentOS 7.3.1611 lvm2-2.02.166-1.el7_3.4.x86_64
SLE11/12 lvm2-2.02.120-72.8.x86_64
openSUSE Tumbleweed 20170510           lvm2-2.02.170-253.1.x86_64

This problem can be reproduced on all of them. For example, on centos:
[root at centos1 loopdevs]# vgchange -ay testvg
   WARNING: Not using lvmetad because config setting use_lvmetad=0.
   WARNING: To avoid corruption, rescan devices to make changes visible (pvscan --cache).
   Error locking on node 1: Volume group for uuid not found: 
wYiWFAj64kucp3e7lgC5m9xtDGFNfwA82tsvS3TzuhXiiLWMknlNpBw1yf5YfVjr

So, I guess how to trigger clvmd to rescan when a object referenced couldn't be found, is I 
should look for:-)

Thanks very much for your input!
Eric
>   
>
> Alasdair
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


