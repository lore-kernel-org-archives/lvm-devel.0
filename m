From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 2 Jul 2010 14:32:41 +0100
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices (v2)
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>
Message-ID: <20100702133241.GK23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 29, 2010 at 03:26:15AM -0400, Takahiro Yasui wrote:
> This is a updated patch (v2) to limit accesses to broken devices.
 
As I mentioned on IRC when you first posted this, my main concern is whether
this introduces new metadata corruption modes (or makes existing ones more
likely to cause problems in given circumstances) if the decision about whether
or not to use a device is per-process and not global (machine and cluster-wide).

Currently the code tries to maintain the list of PVs as a global list which all
instances of LVM tools share.

What is proposed here is to start caching the failure information within a
single process.  But for how long can we safely cache it before revalidating
it?  Can there be races between processes?

For example, how do we cope when bad sectors (or transient I/O failures) cause
one LVM process to consider a device as missing while another process (using
different sectors) still thinks it's perfectly OK?

Shouldn't there be global decisions about this?

Perhaps decisions to start ignoring devices should be protected by the existing
locks: after dropping whichever lock protects the device, the state is reset and
next time the device is needed it will get retried again.  (In other words the
scope of the 'stop using this device because there were errors' flag is limited
to a single transaction - and of course within that transaction the tool could have
set the MISSING_PV flag to inform other processes to stop using the device.)

Anyway, I agree that we need to do something like this patch, but I think more
complex scenarios need to be considered first.

Alasdair


