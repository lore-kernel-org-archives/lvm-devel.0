From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 23 Mar 2009 17:05:35 +0000
Subject: [PATCH] fix vgcfgrestore segfault if PV is missing
In-Reply-To: <49C3D606.8000101@redhat.com>
References: <49C3D606.8000101@redhat.com>
Message-ID: <20090323170535.GB13664@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 20, 2009 at 06:44:38PM +0100, Milan Broz wrote:
> Fix segfault for vgcfgrestore on VG with missing PVs.

Ack.
 
> +	if (vg_missing_pv_count(vg))
> +		return 0;

return_0

Alasdair
-- 
agk at redhat.com


