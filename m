From: Eric Wheeler <lvm-dev@lists.ewheeler.net>
Date: Tue, 30 Sep 2014 11:38:37 -0700 (PDT)
Subject: dm-thinp feature request: skip allocation on writes of all zeroes
Message-ID: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello all,

We have been testing dm-thinp for the last couple years and it has been 
stable for the most part.

I have always wondered, does LVM ignore writes with blocks of all zeroes 
when the destination address is unallocated? From experience, it does not 
appear that this is so (or I cannot find the config option). This would 
reduce IOs, particularily when importing VM disk images from other 
sources. Currently, we must import, allocate lots of zeroes, then fstrim 
after the fact.

I have paged through the dm-thinp code, but I am not quite certain what 
the best place to add this logic would be such that the IO is completed 
and the allocation is not performed.

I would be happy to work on a patch, but I need a little bit of direction:

What would it take to add this as a feature option to the dmsetup table 
string?

Where in the dm-thinp code would this best be addressed?


--
Eric Wheeler, President           eWheeler, Inc. dba Global Linux Security
888-LINUX26 (888-546-8926)        Fax: 503-716-3878           PO Box 25107
www.GlobalLinuxSecurity.pro       Linux since 1996!     Portland, OR 97298


