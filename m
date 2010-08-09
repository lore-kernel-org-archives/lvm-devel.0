From: ben <benscott@nwlink.com>
Date: Mon, 9 Aug 2010 00:26:40 -0700
Subject: Can't delete "open" snapshots
In-Reply-To: <4C5FA851.9030204@redhat.com>
References: <201008072303.34522.benscott@nwlink.com>
	<4C5FA851.9030204@redhat.com>
Message-ID: <201008090026.40436.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Monday, August 09, 2010 12:03:45 am Peter Rajnoha wrote:
> On 08/08/2010 08:03 AM +0100, ben wrote:
> > Someone recently noted here that they have been having trouble deleting
> > snapshots. I have been seeing the same behaviour with that latest CVS
> > builds. I can create a snap, run "lvs", then try to delete the snapshot.
> > Sometimes it will delete but more often lvremove complains the snap is
> > "open" and refuses.
> 
> I suppose this is the same as:
>   https://bugzilla.redhat.com/show_bug.cgi?id=577798
> 
> Can you try killing udev daemon temporarily with "killall udevd" and see
> if you can reproduce? What distribution do you use?
> 
> Basically, we have problem supporting the "watch" rule, so you can also
> try and see if that one is used somewhere
> 
>   grep watch /lib/udev/rules.d/* /etc/udev/rules.d/*
> 
> (..most of the time it's the "watch" rule set in udisks' udev rules)
> 
> Peter

I removed 'udisk' and the problem seems to be gone. I am running
Debian unstable. Thank you.


