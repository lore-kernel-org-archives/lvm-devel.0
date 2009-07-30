From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 30 Jul 2009 15:10:52 -0400 (EDT)
Subject: crash in dmeventd
In-Reply-To: <8763de18tt.fsf@twilight.int.mornfall.net.>
References: <Pine.LNX.4.64.0907141942420.6368@hs20-bc2-1.build.redhat.com>
	<8763de18tt.fsf@twilight.int.mornfall.net.>
Message-ID: <Pine.LNX.4.64.0907301508290.17876@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 27 Jul 2009, Petr Rockai wrote:

> Mikulas Patocka <mpatocka@redhat.com> writes:
> > I got another crash, when attempting to deactivate snapshot, origin and 
> > two mirrors at once. It seems like there are multiple bugs in dmeventd and 
> > it never worked in upstream code at all, you need to assign it to somebody 
> > to fix it.
> Is this reproducible? If so, could you please instead send output of:
> 
> thread apply all bt full
> 
> Thanks!

It crashes when I activate dmeventd for both snapshots and non-snapshots 
--- i.e. place this into lvm.conf:

dmeventd {
 mirror_library = "libdevmapper-event-lvm2mirror.so"
 snapshot_library = "libdevmapper-event-lvm2snapshot.so"
}

and then activate the volume group with both snapshots and mirrors with 
vgchange -ay and vgchange -an.

When I activate volumes one-by-one with lvchange, it is somehow more 
stable.

Mikulas


