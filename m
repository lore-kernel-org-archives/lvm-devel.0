From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 07 Aug 2013 16:35:40 +0200
Subject: master - RAID: Make "raid1" the default mirror segment type
In-Reply-To: <A3DC30E4-972E-4577-B461-5BD04E42FDF9@redhat.com>
References: <20130806191451.F216960F6C@fedorahosted.org>
	<520211A8.3010901@gmail.com>
	<A3DC30E4-972E-4577-B461-5BD04E42FDF9@redhat.com>
Message-ID: <52025B3C.9060309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/07/2013 04:03 PM, Brassow Jonathan wrote:
> 
> On Aug 7, 2013, at 4:21 AM, Zdenek Kabelac wrote:
> 
>>
>> We need fallback here - since if the user doesn't have dm-raid -  then he needs to manually configure defaults.
>>
>> As a result automated tests on systems without dm raid fails.
>>
>> Also we need to update all tests which were supposed to test mirrors,
>> to really test mirrors - otherwise we are checking raid code twice
>> (and even without checking  dm-raid version presence)
> 
> I'll fix-up all the mirror tests today.
> 
> Not sure about what to do regarding a user on an old system with fresh LVM.  The commands should complain about not having RAID kernel support.  Do we overwrite their current lvm.conf when installing?  I don't think so...
> 

We do have a patch attached to RHEL5 already that removes some RAID stuff from lvm.conf
(the mirror_segtype_default setting):

  http://pkgs.devel.redhat.com/cgit/rpms/lvm2/tree/lvm2-rhel5.patch?h=rhel-5.9

We can change that if needed...

Peter


