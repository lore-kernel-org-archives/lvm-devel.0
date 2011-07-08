From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 08 Jul 2011 13:36:20 +0200
Subject: LVM2/test/lib aux.sh
In-Reply-To: <20110708100543.16319.qmail@sourceware.org>
References: <20110708100543.16319.qmail@sourceware.org>
Message-ID: <4E16EBB4.2060507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 8.7.2011 12:05, zkabelac at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	zkabelac at sourceware.org	2011-07-08 10:05:43
>
> Modified files:
> 	test/lib       : aux.sh
>
> Log message:
> 	Increase timeout for udev settle
> 	
> 	For some unknown reason (atm) udev settle takes longer time on recent rawhide.
> 	To pass the test - inrease the settle timeout.
>
>

Ok - so it seem like 'enabling' global watch rule (as has been made on a 
problematic machine in 60-persistent-storage.rules) was not really good idea.
(problem of md* and dm*)

Zdenek


