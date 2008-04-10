From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 10 Apr 2008 17:26:26 +0100
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
In-Reply-To: <47FB4F07.5070909@redhat.com>
References: <20080407221238.30851.qmail@sourceware.org>
	<47FB4F07.5070909@redhat.com>
Message-ID: <20080410162626.GO2572@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 08, 2008 at 11:55:03AM +0100, Bryn M. Reeves wrote:
> In that case, vginfo_from_vgname returns NULL - we
> cannot rely on getting the format type from the cache since that
> requires there to always be at least one orphan for each format type
> on-disk (or we need to change the cache to make one up in that case).

> Unless you already have at least one orphan PV of the same format type.

I changed the cache to be pre-populated with all the orphan VGs, even if they
contain no PVs.
 
Alasdair
-- 
agk at redhat.com


