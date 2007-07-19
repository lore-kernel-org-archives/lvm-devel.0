From: Omri Schwarz <ocschwar@MIT.EDU>
Date: Thu, 19 Jul 2007 18:23:18 -0000
Subject: Getting lvchange & vgchange to take UUIDs.
Message-ID: <Pine.GSO.4.64L.0707191414040.26048@no-knife.mit.edu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hi, all. It's great that vgrename will help with
namespace conflict by taking UUIDs. That helps when
you have to do the hard drive shuffle. But when the
offending volume group has active logical volumes,
it would be nice if they could be inactivated by UUID
too.

Is anyone doing that at the moment?


Omri Schwarz --- ocschwar at mit.edu
Timeless wisdom of biomedical engineering: "Noise is principally
due to the presence of the patient." -- R.F. Farr


