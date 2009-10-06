From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 06 Oct 2009 12:10:14 -0400
Subject: [PATCH] [DRAFT] Binary backups (aka pvcreate --undo, RHBZ#174701)
In-Reply-To: <871vlhcyag.fsf@twilight.int.mornfall.net.>
References: <871vlhcyag.fsf@twilight.int.mornfall.net.>
Message-ID: <1254845414.2455.14.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

One initial comment about "pvcreate --undo".

I'm wondering whether we should start moving recovery options to
separate commands altogether.  For instance,
- pv{repair|restore}

This would be analogous to vgcfgrestore.  We might also think about
moving the pvcreate restore options (--uuid, --restorefile) to this
new command.

I think eventually we will deprecate pvcreate in favor of
vgcreate/vgextend.




