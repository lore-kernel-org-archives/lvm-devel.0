From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 16 Feb 2009 19:08:06 +0000
Subject: [PATCH] Use vgid as well as vgname in lvmcache_update_vg().
In-Reply-To: <1234048029-29850-1-git-send-email-dwysocha@redhat.com>
References: <1234048029-29850-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20090216190806.GA26197@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Feb 07, 2009 at 06:07:09PM -0500, Dave Wysochanski wrote:
> With duplicate vgnames in a system, vg metadata could get
> exported to the wrong lvmcache_vginfo structure.  Use the vg_uuid as
> well as the name to lookup the vginfo structure before we store the
> metadata.
 
Did you construct any test case where this actually goes wrong?

Alasdair
-- 
agk at redhat.com


