From: Brassow Jonathan <jbrassow@redhat.com>
Date: Wed, 7 Aug 2013 11:42:44 -0500
Subject: master - RAID: Make "raid1" the default mirror segment type
In-Reply-To: <52025B3C.9060309@redhat.com>
References: <20130806191451.F216960F6C@fedorahosted.org>
	<520211A8.3010901@gmail.com>
	<A3DC30E4-972E-4577-B461-5BD04E42FDF9@redhat.com>
	<52025B3C.9060309@redhat.com>
Message-ID: <82E23FFA-F01A-4859-BDDD-88587A24E81B@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Aug 7, 2013, at 9:35 AM, Peter Rajnoha wrote:

> On 08/07/2013 04:03 PM, Brassow Jonathan wrote:
>> 
>> On Aug 7, 2013, at 4:21 AM, Zdenek Kabelac wrote:
>> 
>>> 
>>> We need fallback here - since if the user doesn't have dm-raid -  then he needs to manually configure defaults.
>>> 
>>> As a result automated tests on systems without dm raid fails.
>>> 
>>> Also we need to update all tests which were supposed to test mirrors,
>>> to really test mirrors - otherwise we are checking raid code twice
>>> (and even without checking  dm-raid version presence)
>> 
>> I'll fix-up all the mirror tests today.
>> 
>> Not sure about what to do regarding a user on an old system with fresh LVM.  The commands should complain about not having RAID kernel support.  Do we overwrite their current lvm.conf when installing?  I don't think so...
>> 
> 
> We do have a patch attached to RHEL5 already that removes some RAID stuff from lvm.conf
> (the mirror_segtype_default setting):
> 
>  http://pkgs.devel.redhat.com/cgit/rpms/lvm2/tree/lvm2-rhel5.patch?h=rhel-5.9
> 
> We can change that if needed...

We will definitely need to do that - and for RHEL6 now too.  RAID1/10 should only become the default upstream and in RHEL7.

I think Zdenek was talking mostly about users who compile their own LVM on machines with older kernels though.

 brassow



