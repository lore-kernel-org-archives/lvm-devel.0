From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 29 Apr 2011 13:40:09 +0100
Subject: LVM2/lib locking/locking.c locking/locking.h m ...
In-Reply-To: <4DBAADF4.2060507@redhat.com>
References: <20110428203001.9308.qmail@sourceware.org>
	<4DBAADF4.2060507@redhat.com>
Message-ID: <20110429124009.GM32370@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > +#define LCK_VG_SYNC		(LCK_NONE | LCK_CACHE)
> > +#define LCK_VG_SYNC_LOCAL	(LCK_NONE | LCK_CACHE | LCK_LOCAL)

> I think this 'cleanup' patch is rather going in opposite direction ?
 
I want to be able to see all the combinations of flags that are used 
listed in one place, not scattered throughout the code.  That's what the
#defines I added are for.

Alasdair


