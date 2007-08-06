From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 6 Aug 2007 20:40:18 +0100
Subject: write-to-stdout failure not detected
In-Reply-To: <87ir7sd5e1.fsf@rho.meyering.net>
References: <87ir7sd5e1.fsf@rho.meyering.net>
Message-ID: <20070806194018.GL2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 06, 2007 at 05:55:34PM +0200, Jim Meyering wrote:
> Last week I spotted a problem with all LVM stdout-writing tools: e.g.,
> vgs > /dev/full mistakenly exits successfully (should exit nonzero

Needs some thought - and probably needs to be customisable - stdout from 'pvs'
vs. nice-to-have log file etc.

Alasdair
-- 
agk at redhat.com


