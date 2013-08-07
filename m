From: Brassow Jonathan <jbrassow@redhat.com>
Date: Wed, 7 Aug 2013 09:03:55 -0500
Subject: master - RAID: Make "raid1" the default mirror segment type
In-Reply-To: <520211A8.3010901@gmail.com>
References: <20130806191451.F216960F6C@fedorahosted.org>
	<520211A8.3010901@gmail.com>
Message-ID: <A3DC30E4-972E-4577-B461-5BD04E42FDF9@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Aug 7, 2013, at 4:21 AM, Zdenek Kabelac wrote:

> 
> We need fallback here - since if the user doesn't have dm-raid -  then he needs to manually configure defaults.
> 
> As a result automated tests on systems without dm raid fails.
> 
> Also we need to update all tests which were supposed to test mirrors,
> to really test mirrors - otherwise we are checking raid code twice
> (and even without checking  dm-raid version presence)

I'll fix-up all the mirror tests today.

Not sure about what to do regarding a user on an old system with fresh LVM.  The commands should complain about not having RAID kernel support.  Do we overwrite their current lvm.conf when installing?  I don't think so...

 brassow


