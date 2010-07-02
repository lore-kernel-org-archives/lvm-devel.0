From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 2 Jul 2010 11:46:56 +0100
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/comma ...
In-Reply-To: <87aaqai7be.fsf@twilight.int.mornfall.net.>
References: <20100702020959.8357.qmail@sourceware.org>
	<87aaqai7be.fsf@twilight.int.mornfall.net.>
Message-ID: <20100702104656.GI23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 02, 2010 at 11:03:49AM +0200, Peter Rockai wrote:
> Have you forgotten to cvs add filter-suspended.[hc]?

Rather - forgot to remove the #include line after deciding it was
pointless bloat to make it into a separate filter.

> hand, I am not convinced that it helps in Mikul??'s case (RHBZ
> 598135). 

I already fixed that bug, which was a case where the cache became
internally inconsistent.

> In his case, the device would still end up in valid_devices in
> the persistent cache and as long as it was just a regular (non-dm) block
> device or partition, the appearance of MD metadata could go unnoticed.

That's a different case from the one he reported and not a problem
(apart from the races I already mentioned): before LVM takes a
non-dm block device and turns it into a PV it checks for MD metadata
as part of the 'pvcreate' functionality.
Neil will be adding a reciprocal check into mdadm, which is the only
way to stop the opposite problem of mdadm clobbering a PV.
 
But without system-wide locking and co-operation between all the admin
tools there are always going to be races possible if admins perform
conflicting commands.  All of the caching code is about choosing a
delicate compromise.

Alasdair


