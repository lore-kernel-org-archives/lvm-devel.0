From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Jul 2010 14:28:32 +0100
Subject: [PATCH] pid files cleanup
In-Reply-To: <4C372207.9060107@redhat.com>
References: <4C36E604.6090106@redhat.com>
	<20100709131139.GY22664@agk-dp.fab.redhat.com>
	<4C372207.9060107@redhat.com>
Message-ID: <20100709132832.GA22664@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 09, 2010 at 03:20:07PM +0200, Fabio M. Di Nitto wrote:
> Ok. Unless there is more than one dm-daemon, there is no benefit to move
> it there.
 
Code like this that we want available to both dm components and LVM components
we *move* to libdevmapper.  So just take it out of lvm-file.c and put it into
libdm-file.c with a dm_ prefix on the name and the fn prototype in libdevmapper.h
in the "file/stream manipulation" section and a comment there that it's the
caller's responsibility to unlink the file before exiting.

Alasdair


