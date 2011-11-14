From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 14 Nov 2011 21:34:02 +0000
Subject: [PATCH 1/5] Add static _check_pv_sizes() function to check all pv sizes for consistency.
In-Reply-To: <1321305181-28158-2-git-send-email-dwysocha@redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
	<1321305181-28158-2-git-send-email-dwysocha@redhat.com>
Message-ID: <20111114213402.GK4396@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Nov 14, 2011 at 04:12:57PM -0500, Dave Wysochanski wrote:
> This function should be called from vg_validate() and vg_read_internal() at
> the very least, barring some condition I have not thought of.  Whether

--setphysicalvolumesize

Alasdair


