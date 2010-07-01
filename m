From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 1 Jul 2010 20:52:36 +0100
Subject: [RFC] remove the persistent filter
In-Reply-To: <87pqz7ij9i.fsf@twilight.int.mornfall.net.>
References: <87aaqcjjvc.fsf@twilight.int.mornfall.net.>
	<87pqz7ij9i.fsf@twilight.int.mornfall.net.>
Message-ID: <20100701195236.GG23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is up for review as part of the udev cache integration work.
The filter was intended to be recording persistently which PVs are in
which VGs - which is where its best value would come from - but that
still hasn't been added to it, years later.  Its value diminished after
/sys/block appeared and was used.

You can always test its value on any specific system by
disabling it in lvm.conf (devices/write_cache_state = 0).

Alasdair


