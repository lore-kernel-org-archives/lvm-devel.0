From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 17 Feb 2009 19:01:24 +0000
Subject: [PATCH 0/3] Test case for demonstrating lvmcache bug with duplicate vgnames
In-Reply-To: <1234839317-20159-1-git-send-email-dwysocha@redhat.com>
References: <20090216190806.GA26197@agk.fab.redhat.com>
	<1234839317-20159-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20090217190124.GF26197@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks.  I've checked in a variation on this, which ensures that
the VG metadata is indexed only by the VG uuid it contains.
(This should already have been updated in the cache earlier.)
I've also added the vgid to the debug message issued when the cache is
updated.

Alasdair
-- 
agk at redhat.com


